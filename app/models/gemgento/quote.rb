module Gemgento

  # @author Gemgento LLC
  class Quote < ActiveRecord::Base
    belongs_to :store, class_name: 'Store'
    belongs_to :user, class_name: 'User'
    belongs_to :user_group, class_name: 'UserGroup'

    has_many :line_items, as: :itemizable, dependent: :destroy
    has_many :products, through: :line_items

    has_one :order, class_name: '::Gemgento::Order'
    has_one :payment, as: :payable, dependent: :destroy
    has_one :billing_address, -> { where is_billing: true }, class_name: 'Address', as: :addressable, dependent: :destroy
    has_one :shipping_address, -> { where is_shipping: true }, class_name: 'Address', as: :addressable, dependent: :destroy

    accepts_nested_attributes_for :billing_address
    accepts_nested_attributes_for :shipping_address
    accepts_nested_attributes_for :payment

    attr_accessor :push_customer, :push_addresses, :push_shipping_method, :push_payment_method, :subscribe,
                  :same_as_billing, :same_as_shipping, :destroy_after_rollback

    serialize :coupon_codes, Array
    serialize :gift_card_codes, Array

    validates :customer_email, format: /@/, allow_nil: true
    validates :billing_address, :shipping_address, presence: true, if: -> { push_addresses.to_bool }
    validates :shipping_method, presence: true, if: -> { push_shipping_method.to_bool }

    before_validation :copy_billing_address_to_shipping_address, if: -> { same_as_billing.to_bool }
    before_validation :copy_shipping_address_to_billing_address, if: -> { same_as_shipping.to_bool }

    before_create :create_magento_quote, if: -> { magento_id.nil? }

    before_save :set_magento_customer, if: -> { push_customer.to_bool }
    before_save :set_magento_addresses, if: -> { push_addresses.to_bool }
    before_save :set_magento_shipping_method, if: -> { push_shipping_method.to_bool }
    before_save :set_magento_payment_method, if: -> { push_payment_method.to_bool }

    after_save :create_subscriber, if: -> { subscribe.to_bool }

    after_rollback :self_destruct, if: -> { destroy_after_rollback == true }

    # Get the current quote given a quote_id, Store, and User.
    #
    # @param store [Gemgento::Store]
    # @param quote_id [Integer]
    # @param user [Gemgento::User]
    # @return [Gemgento:Quote]
    def self.current(store, quote_id = nil, user = nil)

      if !quote_id.blank? && user.nil? # quote_id but no current_user
        quote = Quote.where('created_at >= ?', Date.today - 30.days).
            find_by(id: quote_id, store: store, converted_at: nil)
        quote = Quote.new(store: store) if quote.nil?

      elsif !quote_id.blank? && !user.nil? # quote_id and current_user
        quote = Quote.where('created_at >= ?', Date.today - 30.days).
            find_by(id: quote_id, store: store, converted_at: nil)

        if quote.nil? || (!quote.user.nil? && quote.user != user) # when quote does not belong to user
          quote = Quote.where('created_at >= ?', Date.today - 30.days).
              find_by(id: quote_id, store: store, user: user, converted_at: nil)
          quote = Quote.new(store: store) if quote.nil?
        end

      elsif quote_id.blank? && !user.nil? # no quote id and a current_user
        quote = Quote.where('created_at >= ?', Date.today - 30.days).
            where(store: store, user: user, converted_at: nil).
            order(updated_at: :desc).first_or_initialize
        quote.reset unless quote.magento_id.nil?

      else
        quote = Quote.new(store: store)
      end

      return quote
    end

    # Quote totals.
    #
    # @return [Hash]
    def totals
      @totals ||= set_totals
    end

    # Fetch quote totals from Magento.
    #
    # @return [Array(Hash), nil]
    def get_totals
      response = API::SOAP::Checkout::Cart.totals(self)

      if response.success?
        return response.body[:result][:item]
      else
        handle_magento_response(response)
        return nil
      end
    end

    # Recalculate quote totals.
    #
    # @return [Hash]
    def reset_totals
      @totals = set_totals
    end

    # Apply a gift card to quote.
    #
    # @param code [String] gift card code
    # @return [Boolean]
    def apply_gift_card(code)
      response = API::SOAP::GiftCard.quote_add(self.magento_id, code, self.store.magento_id)

      if response.success?
        self.gift_card_codes << code unless self.gift_card_codes.include? code
        save
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Remove a gift card from quote.
    #
    # @param code [String] gift card code
    # @return [Boolean] true if the gift card was removed, otherwise an error message.
    def remove_gift_card(code)
      response = API::SOAP::GiftCard.quote_remove(self.magento_id, code, self.store.magento_id)

      if response.success?
        self.gift_card_codes.delete code
        save
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Apply a coupon code to the quote.
    #
    # @param code [String] coupon code
    # @return [Boolean]
    def apply_coupon(code)
      response = API::SOAP::Checkout::Coupon.add(self, code)

      if response.success?
        self.coupon_codes << code unless self.coupon_codes.include? code
        save
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Remove a coupon code from the quote.
    #
    # @return [Boolean]
    def remove_coupons
      response = API::SOAP::Checkout::Coupon.remove(self)

      if response.success?
        self.coupon_codes = []
        self.save
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Set quote customer in Magento.
    #
    # @return [Boolean]
    def set_magento_customer
      response = API::SOAP::Checkout::Customer.set(self)

      if response.success?
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Push Quote shipping and billing addresses to Magento.
    #
    # @return [Boolean]
    def set_magento_addresses
      # re-set magento customer if guest so that customer name can be pulled from addresses.
      return false if self.customer_is_guest && !self.set_magento_customer

      response = API::SOAP::Checkout::Customer.address(self)

      if response.success?
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Fetch available shipping methods from Magento.
    #
    # @return [Array(Hash)]
    def shipping_methods
      response =  API::SOAP::Checkout::Shipping.list(self)

      if response.success?
        return [] if response.body[:result][:item].nil?
        response.body[:result][:item] = [response.body[:result][:item]] unless response.body[:result][:item].is_a? Array

        return response.body[:result][:item]
      else
        handle_magento_response(response)
        return []
      end
    end

    # Get the shipping method price.
    #
    # @param selected_method [String]
    # @param shipping_methods [Array(Hash), nil]
    # @return [BigDecimal]
    def get_shipping_amount(selected_method, shipping_methods = nil)
      shipping_methods = self.shipping_methods if shipping_methods.blank?

      shipping_methods.each do |shipping_method|
        if shipping_method[:code] == selected_method
          return shipping_method[:price].to_d
        end
      end

      return 0.0
    end

    # Set Quote shipping method in Magento.
    #
    # @return [Boolean]
    def set_magento_shipping_method
      response = API::SOAP::Checkout::Shipping.method(self, self.shipping_method)

      if response.success?
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Get payment methods from Magento.
    #
    # @return [Array(Hash), nil]
    def payment_methods
      response = API::SOAP::Checkout::Payment.list(self)
      response.body[:result]

      if response.success?
        return response.body[:result]
      else
        handle_magento_response(response)
        return nil
      end
    end

    def set_magento_payment_method
      response = API::SOAP::Checkout::Payment.method(self, self.payment)

      if response.success?
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Convert a Quote to an Order.
    #
    # @return [Boolean]
    def convert(remote_ip = nil)
      before_convert
      response = API::SOAP::Checkout::Cart.order(self, self.payment, remote_ip)

      if response.success?
        self.mark_converted!(response.body[:result])
        return true

      else
        handle_magento_response(response)
        after_convert_fail
        return false
      end

    end

    # Mark a quote as converted.  Ensures the Order data is fetched from Magento and calls
    # the after_convert_success method.
    #
    # @param increment_id [Integer]
    # @return [Void]
    def mark_converted!(increment_id)
      Gemgento::API::SOAP::Sales::Order.fetch(increment_id)
      self.converted_at = Time.now
      self.save
      self.reload

      if self.user && Config[:extensions]['authorize-net-cim-payment-module']
        Gemgento::API::SOAP::Authnetcim::Payment.fetch(self.user)
      end

      after_convert_success
    end

    def before_convert

    end

    def after_convert_success
      push_gift_message_comment unless self.gift_message.blank?
    end

    def after_convert_fail

    end

    def as_json(options = nil)
      result = super
      result['user'] = self.user
      result['line_items'] = self.line_items
      result['shipping_address'] = self.shipping_address
      result['billing_address'] = self.billing_address
      result['payment'] = self.payment
      return result
    end

    # Calculate the subtotal of the Quote.
    #
    # @return [BigDecimal]
    def subtotal
      if self.line_items.any?
        return self.line_items.map{ |li| li.price * li.qty_ordered.to_d }.inject(&:+)
      else
        return 0
      end
    end

    # Total quantity of line items.
    #
    # @return [BigDecimal]
    def item_quantity
      line_items.sum(:qty_ordered).to_d
    end

    # Reset quote data to before checkout began.
    #
    # @return [Void]
    def reset
      self.user_id = nil
      self.customer_email = nil
      self.billing_address.destroy unless self.billing_address.nil?
      self.shipping_address.destroy unless self.shipping_address.nil?
      self.shipping_method = nil
      self.shipping_amount = nil
      self.payment.destroy unless self.payment.nil?
      self.save
    end

    # Push the gift_message to associated Magento Order as a comment.
    #
    # @return [Void]
    def push_gift_message_comment
      API::SOAP::Sales::Order.add_comment(self.order.increment_id, self.order.status, "Gemgento Gift Message: #{self.gift_message}")
      order.update(gift_message: self.gift_message)
    end

    # Determine if a shipping method is required for the Quote.
    #
    # @return [Boolean]
    def shipping_method_required?
      self.line_items.collect do |li|
        return true if li.product.magento_type != 'giftvoucher'
      end

      return false
    end

    private

    # Create the quote in Magento.  Used as a before_create callback.
    #
    # @return [Void]
    def create_magento_quote
      response = API::SOAP::Checkout::Cart.create(self)

      if response.success?
        self.magento_id = response.body[:quote_id]
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Create a Subscriber from the Quote User.
    #
    # @return [Gemgento::Subscriber]
    def create_subscriber
      Subscriber.create(email: self.customer_email)
    end

    # Duplicate the billing address to use as shipping address.
    #
    # @return [Void]
    def copy_billing_address_to_shipping_address
      Rails.logger.debug 'Copying billing address to shipping address'
      self.build_shipping_address if self.shipping_address.nil?
      self.shipping_address.attributes = self.billing_address.duplicate.attributes.reject{ |k| k == 'id' }.merge(
          {
              id: self.shipping_address ? self.shipping_address.id : nil,
              address1: self.billing_address.address1,
              address2: self.billing_address.address2,
              address3: self.billing_address.address3,
              is_shipping: true,
              is_billing: false
          }
      )
      self.shipping_address.addressable = self
    end

    # Duplicate the shipping address to use as billing address.
    #
    # @return [Void]
    def copy_shipping_address_to_billing_address
      Rails.logger.debug 'Copying shipping address to billing address'
      self.build_billing_address if self.billing_address.nil?
      self.billing_address.attributes = self.shipping_address.duplicate.attributes.reject{ |k| k == 'id' }.merge(
          {
              id: self.billing_address ? self.billing_address.id : nil,
              address1: self.shipping_address.address1,
              address2: self.shipping_address.address2,
              address3: self.shipping_address.address3,
              is_shipping: false,
              is_billing: true
          }
      )
      self.billing_address.addressable = self
    end

    # Set quote totals based on Magento API call.
    #
    # @return [Hash]
    def set_totals
      magento_totals = self.get_totals
      totals = {
          subtotal: 0,
          discounts: {},
          gift_card: 0,
          nominal: {},
          shipping: 0,
          tax: 0,
          total: 0
      }

      unless magento_totals.nil?
        magento_totals.each do |total|
          unless total[:title].include? 'Discount'
            if !total[:title].include? 'Nominal' # regular checkout values
              if total[:title].include? 'Subtotal'
                totals[:subtotal] = total[:amount].to_f
                totals[:subtotal] = self.subtotal if totals[:subtotal] == 0
              elsif total[:title].include? 'Grand Total'
                totals[:total] = total[:amount].to_f
              elsif total[:title].include? 'Tax'
                totals[:tax] = total[:amount].to_f
              elsif total[:title].include? 'Shipping'
                totals[:shipping] = total[:amount].to_f
              elsif total[:title].include? 'Gift Card'
                totals[:gift_card] = total[:amount].to_f
              end
            else # checkout values for a nominal item
              if total[:title].include? 'Subtotal'
                totals[:nominal][:subtotal] = total[:amount].to_f
                totals[:nominal][:subtotal] = self.subtotal if totals[:nominal][:subtotal] == 0
              elsif total[:title].include? 'Total'
                totals[:nominal][:total] = total[:amount].to_f
              elsif total[:title].include? 'Tax'
                totals[:nominal][:tax] = total[:amount].to_f
              elsif total[:title].include? 'Shipping'
                totals[:nominal][:shipping] = total[:amount].to_f
              elsif total[:title].include? 'Gift Card'
                totals[:gift_card] == total[:amount].to_f
              end
            end
          else
            code = total[:title][10..-2]
            totals[:discounts][code.to_sym] = total[:amount].to_f
          end
        end

        # if subtotal is not zero and total is zero, we need to calculate total to ensure it should be zero.
        # Magento may not have calculated total because of missing addresses, shipping methods, etc.
        if totals[:total].zero? && !totals[:subtotal].zero?
          totals[:total] += totals[:subtotal]
          totals[:total] += totals[:shipping]
          totals[:total] += totals[:tax]
          totals[:total] -= totals[:gift_card].abs
          totals[:total] -= totals[:discounts].values.inject(0, :+).abs
          totals[:total] = totals[:total].round(2) # fix loss of float precision
        end

        # nominal shipping isn't calculated correctly, so we can set it based on known selected values
        if !totals[:nominal].has_key?(:shipping) && totals[:nominal].has_key?(:subtotal) && self.shipping_address
          if totals[:shipping] && totals[:shipping] > 0
            totals[:nominal][:shipping] = totals[:shipping]
          elsif shipping_method = get_magento_shipping_method
            totals[:nominal][:shipping] = shipping_method['price'].to_f
          else
            totals[:nominal][:shipping] = 0.0
          end

          totals[:nominal][:total] += totals[:nominal][:shipping] if totals[:nominal].has_key?(:total) # make sure the grand total reflects the shipping changes
        end
      end

      return totals
    end

    # Handle the Magento create/update/destroy response.  Mark self for destruction if it no longer exists in Magento.
    #
    # @param response [Gemgento::MagentoResponse]
    # @return [Void]
    def handle_magento_response(response)
      if response.body[:faultcode].to_i == 1002 # quote doesn't exist in Magento.
         self.destroy_after_rollback = true
      else
        self.errors.add(:base, response.body[:faultstring])
      end
    end

    def self_destruct
      LineItem.skip_callback(:destroy, :before, :destroy_magento_quote_item)
      self.destroy
      LineItem.set_callback(:destroy, :before, :destroy_magento_quote_item)
    end

  end
end