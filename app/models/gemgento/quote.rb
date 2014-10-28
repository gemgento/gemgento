module Gemgento
  class Quote < ActiveRecord::Base
    belongs_to :store, class_name: 'Store'
    belongs_to :user, class_name: 'User'
    belongs_to :user_group, class_name: 'UserGroup'
    belongs_to :shipping_address, foreign_key: 'shipping_address_id', class_name: 'Address'
    belongs_to :billing_address, foreign_key: 'billing_address_id', class_name: 'Address'

    has_many :line_items, as: :itemizable
    has_many :products, through: :line_items

    has_one :payment, as: :payable
    has_one :order

    accepts_nested_attributes_for :billing_address
    accepts_nested_attributes_for :shipping_address
    accepts_nested_attributes_for :payment

    attr_accessor :tax, :total, :push_quote_customer, :subscribe

    validates :customer_email, format: /@/, allow_nil: true

    before_create :create_magento_quote, if: 'magento_id.nil?'

    # Get the current quote given a quote_id, Store, and User.
    #
    # @param store [Gemgento::Store]
    # @param quote_id [Integer]
    # @param user [Gemgento::User]
    # @return [Gemgento:Quote]
    def self.current(store, quote_id = nil, user = nil)

      if !quote_id.blank? && user.nil?
        quote = Quote.where('created_at >= ?', Date.today - 30.days).
            find_by(id: quote_id, store: store)
        quote = Quote.new(store: store) if quote.nil?

      elsif !quote_id.blank? && !user.nil?
        quote = Quote.where('created_at >= ?', Date.today - 30.days).
            find_by(id: quote_id, store: store)

        if quote.nil? || (!quote.user.nil? && quote.user != user)
          quote = Quote.where('created_at >= ?', Date.today - 30.days).
              find_by(id: quote_id, store: store, user: user)
          quote = Quote.new(store: store)
        end
      elsif quote_id.blank? && !user.nil?
        quote = Quote.where(store: store, user: user).
            where('created_at >= ?', Date.today - 30.days).
            quote(updated_at: :desc).first_or_initialize
        quote.reset_checkout unless quote.magento_quote_id.nil?
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
        self.errors.add(:base, response.body[:faultstring])
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
      response = API::SOAP::GiftCard.quote_add(self.magento_quote_id, code, self.store.magento_id)

      if response.success?
        return true
      else
        errors.add :base, response.body[:faultstring]
        return false
      end
    end

    # Remove a gift card from quote.
    #
    # @param code [String] gift card code
    # @return [Boolean] true if the gift card was removed, otherwise an error message.
    def remove_gift_card(code)
      response = API::SOAP::GiftCard.quote_remove(self.magento_quote_id, code, self.store.magento_id)

      if response.success?
        return true
      else
        errors.add :base, response.body[:faultstring]
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
        return true
      else
        errors.add :base, response.body[:faultstring]
        return false
      end
    end

    # Remove a coupon code from the quote.
    #
    # @return [Boolean]
    def remove_coupons
      response = API::SOAP::Checkout::Coupon.remove(self)
            a
      if response.success?
        return true
      else
        errors.add :base, response.body[:faultstring]
        return false
      end
    end

    # Push Quote shipping and billing addresses to Magento.
    #
    # @return [Boolean]
    def push_addresses
      response = API::SOAP::Checkout::Customer.address(self)

      if response.success?
        return true
      else
        self.errors.add(:base, response.body[:faultstring])
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
        self.errors.add(:base, response.body[:faultstring])
        return nil
      end
    end

    # Set Quote payment method in Magento.
    #
    # @return [Boolean]
    def push_payment_method
      response = API::SOAP::Checkout::Payment.method(self, self.payment)

      if response.success?
        return true
      else
        self.errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Set quote customer in Magento.
    #
    # @return [Boolean]
    def push_cart_customer_to_magento
      response = API::SOAP::Checkout::Customer.set(self)

      if response.success?
        return true
      else
        self.errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Fetch available shipping methods from Magento.
    #
    # @return [Array(Hash), nil]
    def shipping_methods
      response =  API::SOAP::Checkout::Shipping.list(self)

      if response.success?
        response.body[:result][:item] = [response.body[:result][:item]] unless response.body[:result][:item].is_a? Array

        return response.body[:result][:item]
      else
        self.errors.add(:base, response.body[:faultstring])
        return nil
      end
    end

    # Set Quote shipping method in Magento.
    #
    # @return [Boolean]
    def push_shipping_method
      response = API::SOAP::Checkout::Shipping.method(self, self.shipping_method)

      if response.success?
        return true
      else
        self.errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Convert a Quote to an Order.
    #
    # @return [Boolean]
    def convert(remote_ip = nil)
      before_conversion
      response = API::SOAP::Checkout::Cart.order(self, self.payment, remote_ip)

      if response.success?
        order = API::SOAP::Sales::Order.fetch(self.increment_id) #grab all the new order information

        HeartBeat.perform_async if Rails.env.production?
        after_conversion

        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Called immediately before Quote is converted into an Order
    def before_conversion
      # for application callbacks
    end

    # Called immediately after Quote is converted into an Order
    def after_conversion
      # for application callbacks
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
        errors.add :base, response.body[:faultstring]
        return false
      end
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
            totals[:discounts][code.to_sym] = total[:amount]
          end
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

  end
end