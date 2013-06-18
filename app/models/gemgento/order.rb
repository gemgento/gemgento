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

  end
end