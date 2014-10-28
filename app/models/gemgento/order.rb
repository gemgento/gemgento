module Gemgento
  class Order < ActiveRecord::Base
    belongs_to :store, class_name: 'Gemgento::Store'
    belongs_to :user, class_name: 'Gemgento::User'
    belongs_to :user_group, class_name: 'Gemgento::UserGroup'
    belongs_to :shipping_address, foreign_key: 'shipping_address_id', class_name: 'Gemgento::Address'
    belongs_to :billing_address, foreign_key: 'billing_address_id', class_name: 'Gemgento::Address'

    has_many :api_jobs, class_name: 'Gemgento::ApiJob', as: :source
    has_many :line_items
    has_many :order_statuses
    has_many :products, through: :line_items
    has_many :shipments
    has_many :shipment_tracks

    has_one :order_payment

    accepts_nested_attributes_for :billing_address
    accepts_nested_attributes_for :shipping_address
    accepts_nested_attributes_for :order_payment

    attr_accessor :tax, :total, :push_cart_customer, :subscribe

    scope :cart, -> { where(state: 'cart') }
    scope :placed, -> { where("state != 'cart'") }

    before_save :push_cart_customer_to_magento, if: :push_cart_customer

    after_commit :subscribe_customer, if: :subscribe

    serialize :cart_item_errors, Array

    validates :customer_email, format: /@/, allow_nil: true

    # CART specific functions

    def self.get_cart(order_id = nil, store = nil, user = nil)
      store = Gemgento::Store.current if store.nil?

      if !order_id.blank? && user.nil?
        cart = Gemgento::Order.where('created_at >= ?', Date.today - 30.days).
            find_by(id: order_id, state: 'cart', store: store)
        cart = Gemgento::Order.new(state: 'cart', store: store) if cart.nil?

      elsif !order_id.blank? && !user.nil?
        cart = Gemgento::Order.where('created_at >= ?', Date.today - 30.days).
            find_by(id: order_id, state: 'cart', store: store)

        if cart.nil? || (!cart.user.nil? && cart.user != user)
          cart = Gemgento::Order.where('created_at >= ?', Date.today - 30.days).
              find_by(id: order_id, state: 'cart', store: store, user: user)
          cart = Gemgento::Order.new(state: 'cart', store: store)
        end
      elsif order_id.blank? && !user.nil?
        cart = Gemgento::Order.cart.where(state: 'cart', store: store, user: user).
            where('created_at >= ?', Date.today - 30.days).
            order(updated_at: :desc).first_or_initialize
        cart.reset_checkout unless cart.magento_quote_id.nil?
      else
        cart = Gemgento::Order.new(state: 'cart', store: store)
      end

      return cart
    end

    # Add an item to an order in the cart state.  24180
    #
    # @param [Gemgento::Product] product
    # @param [Float] quantity
    # @param [nil, Hash] options product options
    # @return [Boolean]
    def add_item(product, quantity = 1.0, options = nil, background_worker = false)
      raise 'Order not in cart state' if self.state != 'cart'

      line_item = self.line_items.find_by(product: product)

      if line_item.nil?
        line_item = LineItem.new
        line_item.product = product
        line_item.qty_ordered = quantity
        line_item.order = self
        line_item.options = options
        line_item.save

        if background_worker
          Gemgento::Cart::AddItemWorker.perform_async(line_item.id)
          return true
        else
          self.push_cart if self.magento_quote_id.nil?

          unless self.magento_quote_id.nil?
            response = API::SOAP::Checkout::Product.add(self, [line_item])

            if response.success?
              return true
            else
              line_item.destroy
              self.errors.add(:base, response.body[:faultstring])
              return false
            end
          end
        end


      else
        return self.update_item(product, line_item.qty_ordered + quantity.to_f, options, background_worker)
      end
    end

    # Update an item in an order that is in the cart state.
    #
    # @param [Gemgento::Product] product
    # @param [Float] quantity
    # @param [nil, Hash] options product options
    # @return [Boolean]
    def update_item(product, quantity = 1.0, options = nil, background_worker = false)
      raise 'Order not in cart state' if self.state != 'cart'

      line_item = self.line_items.where(product: product).first

      unless line_item.nil?
        old_quantity = line_item.qty_ordered
        line_item.qty_ordered = quantity.to_f
        line_item.options = options
        line_item.save

        unless self.magento_quote_id.nil?

          if background_worker
            Gemgento::Cart::UpdateItemWorker.perform_async(line_item.id, old_quantity)
            return true
          else
            response = API::SOAP::Checkout::Product.update(self, [line_item])

            if response.success?
              return true
            else
              line_item.qty_ordered = old_quantity
              line_item.save
              self.errors.add(:base, response.body[:faultstring])
              return false
            end
          end
        end
      else
        return self.add_item(product, quantity, options, background_worker)
      end
    end

    # Remove an item from an order in the cart state.
    #
    # @param product [Gemgento::Product]
    # @return [Boolean]
    def remove_item(product)
      raise 'Order not in cart state' if self.state != 'cart'

      if line_item = self.line_items.where(product: product).first
        if self.magento_quote_id.nil?
          line_item.destroy
          return true
        else
          response = API::SOAP::Checkout::Product.remove(self, [line_item])

          if response.success?
            line_item.destroy
            return true
          else
            self.errors.add(:base, response.body[:faultstring])
            return false
          end
        end
      else
        self.errors.add(:base, 'Product is not in the cart')
        return false
      end
    end

    def to_param
      self.increment_id
    end

    def push_cart
      raise 'Cart already pushed, creating a new cart' unless self.magento_quote_id.nil?

      response = API::SOAP::Checkout::Cart.create(self)

      if response.success?
        self.magento_quote_id = response.body[:quote_id]
        save
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    def get_totals
      API::SOAP::Checkout::Cart.totals(self)
    end

    def subtotal
      if self.state != 'cart'
        super
      else
        if self.line_items.any?
          prices = self.line_items.map do |oi|
            if oi.product.magento_type == 'giftvoucher'
              oi.product.gift_price.to_f * oi.qty_ordered.to_f
            else
              oi.product.price(self.user, self.store).to_f * oi.qty_ordered.to_f
            end
          end

          return prices.inject(&:+)
        else
          return 0
        end
      end
    end

    # The total quantity of items in the order.
    #
    # @return [Float]
    def item_count
      line_items.sum(:qty_ordered).to_f
    end

    # Apply a gift card to the order.  Only works in when order is in cart state.
    #
    # @param [String] code gift card code
    # @return [Boolean,String] true if the gift card was applied, otherwise an error message.
    def apply_gift_card(code)
      raise 'Order not in cart state' if self.state != 'cart'
      Gemgento::API::SOAP::GiftCard.quote_add(self.magento_quote_id, code, self.store.magento_id)
    end

    # Remove a gift card from an order.  Only works in when order is in cart state.
    #
    # @param [String] code gift card code
    # @return [Boolean,String] true if the gift card was removed, otherwise an error message.
    def remove_gift_card(code)
      raise 'Order not in cart state' if self.state != 'cart'
      Gemgento::API::SOAP::GiftCard.quote_remove(self.magento_quote_id, code, self.store.magento_id)
    end

    # CHECKOUT methods

    # Set order shipping method and push to Magento.
    #
    # @param selected_method[String] the chosen shipping method code
    # @param shipping_methods[Hash] list of all shipping methods (from API cart shipping methods request)
    # @return [Boolean] true if the shipping method was successfully set
    def set_shipping_method(selected_method, shipping_methods)
      return false if selected_method.blank?

      self.shipping_method = selected_method
      self.shipping_amount = 0

      shipping_methods.each do |shipping_method|
        if shipping_method[:code] == selected_method
          self.shipping_amount = shipping_method[:price]
          break
        end
      end

      if self.push_shipping_method
        self.save
        return true
      else
        return false
      end
    end

    # Set the payment method for an order
    #
    # @param order_payment_attributes[Hash] all attributes for an OrderPayment
    # @return [Boolean] true if the payment method was successfully set
    def set_payment(order_payment_attributes)
      if self.order_payment.nil?
        self.order_payment = Gemgento::OrderPayment.new(order_payment_attributes)
      else
        self.order_payment.attributes = order_payment_attributes
      end

      self.order_payment.cc_last4 = self.order_payment.cc_number[-4..-1]

      return self.order_payment.save && self.push_payment_method
    end


    # Apply a coupon code to the cart.
    #
    # @param code [String] coupon code
    # @return [Boolean] true if the coupon code was successfully applied
    def apply_coupon(code)
      Gemgento::API::SOAP::Checkout::Coupon.add(self, code)
    end

    # Remove a coupon code to the cart.
    #
    # @param code [String] coupon code
    # @return [Boolean] true if the coupon code was successfully removed
    def remove_coupons
      Gemgento::API::SOAP::Checkout::Coupon.remove(self)
    end

    # Order totals for the cart phase.
    #
    # @return [Hash]
    def totals
      @totals ||= set_totals
    end

    # Recalculate order totals.
    #
    # @return [Hash]
    def reset_totals
      @totals = set_totals
    end

    # Set order totals for the cart phase.
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

    # functions related to processing cart into order

    def push_addresses
      API::SOAP::Checkout::Customer.address(self)
    end

    def get_payment_methods
      API::SOAP::Checkout::Payment.list(self)
    end

    def push_payment_method
      raise 'Order payment method has not been set' if self.order_payment.nil?
      API::SOAP::Checkout::Payment.method(self, self.order_payment)
    end

    # Set the cart customer in Magento.
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

    def get_shipping_methods
      raise 'Order shipping address not set' if self.shipping_address.nil?
      return API::SOAP::Checkout::Shipping.list(self)
    end

    def push_shipping_method
      raise 'Order shipping method has not been set' if self.shipping_method.nil?
      API::SOAP::Checkout::Shipping.method(self, self.shipping_method)
    end

    def process(remote_ip = nil)
      if !valid_stock?
        errors.add(:base, 'Some of the order items are now out of stock.')
        return false
      else
        response = API::SOAP::Checkout::Cart.order(self, self.order_payment, remote_ip)

        if response.success?
          self.increment_id = response.body[:result]
          save
          Gemgento::API::SOAP::Sales::Order.fetch(self.increment_id) #grab all the new order information
          reload

          push_gift_message_comment unless self.gift_message.blank?
          Gemgento::HeartBeat.perform_async if Rails.env.production?
          finalize

          return true
        else
          errors.add(:base, response.body[:faultstring])
          return false
        end
      end
    end

    def push_gift_message_comment
      API::SOAP::Sales::Order.add_comment(self.increment_id, self.status, "Gemgento Gift Message: #{self.gift_message}")
    end

    def finalize
      # for application defined post order actions
    end

    def as_json(options = nil)
      result = super
      result['user'] = self.user
      result['line_items'] = self.line_items
      result['shipping_address'] = self.shipping_address
      result['billing_address'] = self.billing_address
      result['payment'] = self.order_payment
      result['statuses'] = self.order_statuses
      result['shipments'] = self.shipments
      return result
    end

    def set_default_billing_address(user)
      if !user.default_billing_address.nil?
        original_address = user.default_billing_address
        address = original_address.duplicate
      elsif !user.address_book.empty?
        original_address = user.address_book.first
        address = original_address.duplicate
      else
        address = Gemgento::Address.new
      end

      self.billing_address = address
    end

    def set_default_shipping_address(user)
      if !user.default_shipping_address.nil?
        original_address = user.default_shipping_address
        address = original_address.duplicate
      elsif !user.address_book.empty?
        original_address = user.address_book.first
        address = original_address.duplicate
      else
        address = Gemgento::Address.new
      end

      self.shipping_address = address
    end

    def reset_checkout
      self.billing_address.destroy unless self.billing_address.nil?
      self.billing_address_id = nil
      self.shipping_address.destroy unless self.shipping_address.nil?
      self.shipping_address_id = nil
      self.shipping_method = nil
      self.shipping_amount = nil
      self.order_payment.destroy unless self.order_payment.nil?
      self.save
    end


    private

    def subscribe_customer
      Gemgento::Subscriber.create(email: self.customer_email)
    end

    def valid_stock?
      self.line_items.each do |item|
        return false unless item.product.in_stock? item.qty_ordered, self.store
      end

      return true
    end

    def verify_address(local_address, remote_address)
      if (
      local_address.first_name != remote_address[:firstname] ||
          local_address.last_name != remote_address[:lastname] ||
          local_address.street != remote_address[:street] ||
          local_address.city != remote_address[:city] ||
          local_address.region != Region.find_by(magento_id: remote_address[:region_id]) ||
          local_address.country != Country.find_by(magento_id: remote_address[:country_id]) ||
          local_address.postcode != remote_address[:postcode]
      )
        self.push_addresses
      end
    end

  end
end