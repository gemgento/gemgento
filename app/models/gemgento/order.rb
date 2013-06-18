module Gemgento
  class Order < ActiveRecord::Base
    belongs_to  :store
    belongs_to  :user
    belongs_to  :user_group
    has_one     :shipping_address, -> { "address_type = 'shipping'" }, class_name: 'Address'
    has_one     :billing_address, -> { "address_type = 'billing'" }, class_name: 'Address'
    has_one     :order_payment
    has_one     :gift_message
    has_many    :order_items
    has_many    :order_statuses

    def self.index
      if Order.find(:all).size == 0
        API::SOAP::Sales::Order.fetch_all
      end

      Order.find(:all)
    end

    # CART specific functions

    def self.get_cart(user)
      cart = Order.find_by(user: user, state: 'cart')

      if cart.nil?
        cart = Order.new
        cart.state = 'cart'
        cart.user = user
        cart.save
      end

      cart
    end

    def add_item(product, quantity = 1)
      raise 'Order not in cart state' if self.state != 'cart'

     if self.order_items.finy_by(product: product).nil?
       order_item = OrderItem.new
       order_item.product = product
       order_item.qty_ordered = quantity
       order_item.save

       unless self.magento_quote_id.nil?
         API::SOAP::Checkout::Product.add(self, [order_item])
       end
     else
       self.update_item(product, quantity)
       end
    end

    def update_item(product, quantity = 1)
      raise 'Order not in cart state' if self.state != 'cart'

      order_item = self.order_items.find_by(product: product)

      unless order_item.nil?
        order_item.qty_ordered = quantity
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

      order_item = self.order_items.find_by(product: product)

      unless order_item.nil?
        API::SOAP::Checkout::Product.remove(self, [order_item])
        order_item.destroy
      end
    end

    def push_cart
      API::SOAP::Checkout::Cart.create(self)
      API::SOAP::Checkout::Product.add(self, self.order_items)
      API::SOAP::Checkout::Cart.totals(self)
    end

    # functions related to processing cart into order

    def push_address(address)
      API::SOAP::Checkout::Customer.address(self, address)
    end

    def get_payment_methods
      API::SOAP::Checkout::Payment.list(self)
    end

    def push_payment_method(payment)
      API::SOAP::Checkout::Payment.method(self, payment)
    end

    def push_customer(user)
      API::SOAP::Checkout::Customer.set(self, user)
    end

    def get_shipping_methods
      API::SOAP::Checkout::Shipping.list(self)
    end

    def push_shipping_method(shipping_method)
      API::SOAP::Checkout::Shipping.method(self, shipping_method)
    end

    def process
      # ensure all essential cart data has been added
      self.push_customer(self.user)
      self.push_address(self.shipping_address)
      self.push_address(self.billing_address)
      self.push_shipping_method(self.shipping_method)
      self.push_payment_method(self.order_payment)

      # process cart to order
      API::SOAP::Checkout::Cart.order(self)
    end
  end
end