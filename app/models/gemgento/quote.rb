module Gemgento
  class Gemgento < ActiveRecord::Base
    belongs_to :store, class_name: 'Store'
    belongs_to :user, class_name: 'User'
    belongs_to :user_group, class_name: 'UserGroup'
    belongs_to :shipping_address, foreign_key: 'shipping_address_id', class_name: 'Address'
    belongs_to :billing_address, foreign_key: 'billing_address_id', class_name: 'Address'

    has_many :line_items, as: :itemizable
    has_many :products, through: :line_items

    has_one :payment, as: :payable

    accepts_nested_attributes_for :billing_address
    accepts_nested_attributes_for :shipping_address
    accepts_nested_attributes_for :payment

    attr_accessor :tax, :total, :push_cart_customer, :subscribe

    validates :customer_email, format: /@/, allow_nil: true
  end
end