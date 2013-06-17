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


    private
    def cart_create_magento
      self.magento_quote_id = Gemgento::Magento.create_call(:shopping_cart_create)
      self.save
    end

    def cart_totals_magento
      response = Gemgento::Magento.create_call(:shopping_cart_totals, { quote_id: self.magento_quote_id })
      response[:result][:item]
    end

    def cart_order_magento
      Gemgento::Magento.create_call(:shopping_cart_order, { quote_id: self.magento_quote_id })
    end

    def cart_customer_set_magento
      message = {
          quote_id: self.magento_quote_id
      }
    end

    def cart_shipping_list_magento
      response = Gemgento::Magento.create_call(:shopping_cart_shipping_list, { quote_id: self.magento_quote_id })
      response[:result][:item]
    end

    def cart_shipping_method_magento
      Gemgento::Magento.create_call(:shopping_cart_shipping_method, { quote_id: self.magento_quote_id, shipping_method: self.shipping_method })
    end

    def cart_payment_list_magento
      response = Gemgento::Magento.create_call(:shopping_cart_payment_list, { quote_id: self.magento_quote_id })
      response[:result]
    end

  end
end