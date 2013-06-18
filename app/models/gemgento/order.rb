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

  end
end