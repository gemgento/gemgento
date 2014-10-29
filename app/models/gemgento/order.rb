module Gemgento
  class Order < ActiveRecord::Base
    belongs_to :store, class_name: 'Store'
    belongs_to :user, class_name: 'User'
    belongs_to :user_group, class_name: 'UserGroup'
    belongs_to :quote, class_name: 'Quote'

    has_many :api_jobs, class_name: 'ApiJob', as: :source
    has_many :line_items, as: :itemizable
    has_many :order_statuses
    has_many :products, through: :line_items
    has_many :shipments
    has_many :shipment_tracks

    has_one :payment, as: :payable
    has_one :billing_address, -> { where is_billing: true }, class_name: 'Address', as: :addressable
    has_one :shipping_address, -> { where is_shipping: true }, class_name: 'Address', as: :addressable

    accepts_nested_attributes_for :billing_address
    accepts_nested_attributes_for :shipping_address
    accepts_nested_attributes_for :payment

    attr_accessor :tax, :total, :push_cart_customer, :subscribe

    after_commit :subscribe_customer, if: :subscribe

    serialize :cart_item_errors, Array

    validates :customer_email, format: /@/, allow_nil: true

    def to_param
      self.increment_id
    end

    def push_gift_message_comment
      API::SOAP::Sales::Order.add_comment(self.increment_id, self.status, "Gemgento Gift Message: #{self.gift_message}")
    end

  end
end