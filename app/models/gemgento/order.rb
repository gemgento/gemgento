module Gemgento
  class Order < ActiveRecord::Base
    belongs_to :store
    belongs_to :user
    belongs_to :user_group

    belongs_to :shipping_address, foreign_key: 'shipping_address_id', class_name: 'Address'
    accepts_nested_attributes_for :shipping_address

    belongs_to :billing_address, foreign_key: 'billing_address_id', class_name: 'Address'
    accepts_nested_attributes_for :billing_address

    has_one :order_payment
    accepts_nested_attributes_for :order_payment

    has_one :gift_message
    has_many :order_items
    has_many :order_statuses

    attr_accessor :tax, :total

    scope :cart, -> { where(state: 'cart') }
    scope :placed, -> { where("state != 'cart'") }

    def self.index
      if Order.all.size == 0
        API::SOAP::Sales::Order.fetch_all
      end

      Order.all
    end

    # CART specific functions

    def self.get_cart(order_id = nil)
      if order_id.nil?
        cart = Order.new
        cart.state = 'cart'
        cart.store = Store.current
      else
        cart = Order.find(order_id)
      end

      cart
    end

    def add_item(product, quantity = 1)
      raise 'Order not in cart state' if self.state != 'cart'

      order_item = self.order_items.where(product: product).first

      if order_item.nil?
        order_item = OrderItem.new
        order_item.product = product
        order_item.qty_ordered = quantity
        order_item.order = self
        order_item.save

        unless self.magento_quote_id.nil?
          API::SOAP::Checkout::Product.add(self, [order_item])
        end
      else
        self.update_item(product, order_item.qty_ordered + quantity.to_i)
      end
    end

    def update_item(product, quantity = 1)
      raise 'Order not in cart state' if self.state != 'cart'

      order_item = self.order_items.where(product: product).first

      unless order_item.nil?
        order_item.qty_ordered = quantity.to_i
        order_item.save

        unless self.magento_quote_id.nil?
          API::SOAP::Checkout::Product.update(self, [order_item])
        end
      else
        self.add_item(product, quantity)
      end
    end

    def remove_item(product)
      raise 'Order not in cart state' if self.state != 'cart'

      order_item = self.order_items.where(product: product).first

      unless order_item.nil?
        API::SOAP::Checkout::Product.remove(self, [order_item]) unless self.magento_quote_id.nil?
        order_item.destroy
      end
    end

    def push_cart
      raise 'Cart already pushed, creating a new cart' unless self.magento_quote_id.nil?
      result = API::SOAP::Checkout::Cart.create(self)

      if !result || self.magento_quote_id.nil?
        self.push_cart
      end

      API::SOAP::Checkout::Product.add(self, self.order_items)
    end

    def get_totals
      API::SOAP::Checkout::Cart.totals(self)
    end

    def item_count
      count = 0

      self.order_items.each do |order_item|
        count += order_item.qty_ordered
      end

      return count.to_i
    end

    # functions related to processing cart into order

    def push_addresses
      API::SOAP::Checkout::Customer.address(self)
    end

    def get_payment_methods
      API::SOAP::Checkout::Payment.list(self)
    end

    def push_payment_method
      API::SOAP::Checkout::Payment.method(self, self.order_payment)
    end

    def push_customer
      API::SOAP::Checkout::Customer.set(self, self.user)
    end

    def get_shipping_methods
      logger.info self.shipping_address.inspect
      raise 'Order shipping address not set' if self.shipping_address.nil?
      @shipping_methods ||= API::SOAP::Checkout::Shipping.list(self)
    end

    def push_shipping_method
      raise 'Shipping method has not been set' if self.shipping_method.nil?
      API::SOAP::Checkout::Shipping.method(self, self.shipping_method)
    end

    def process
      if !valid_stock?
        return false
      elsif API::SOAP::Checkout::Cart.order(self)
        finalize
        return true
      else
        return false
      end
    end

    def enforce_cart_data
      magento_cart = API::SOAP::Checkout::Cart.info(self)
      verify_address(self.shipping_address, magento_cart[:shipping_address])
      verify_address(self.billing_address, magento_cart[:billing_address])
    end

    def finalize
      # for application defined post order actions
    end

    private

    def valid_stock?
      self.order_items.each do |item|
        return false unless item.product.in_stock? item.qty_ordered
      end

      return true
    end

    def verify_address(local_address, remote_address)
      Rails.logger.info remote_address.inspect
      Rails.logger.info local_address.inspect
      if (
        local_address.fname != remote_address[:firstname] ||
        local_address.lname != remote_address[:lastname] ||
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