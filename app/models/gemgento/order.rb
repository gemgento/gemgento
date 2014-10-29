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

    def set_default_billing_address(user)
      if !user.default_billing_address.nil?
        original_address = user.default_billing_address
        address = original_address.duplicate
      elsif !user.address_book.empty?
        original_address = user.address_book.first
        address = original_address.duplicate
      else
        address = Address.new
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
        address = Address.new
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
      self.payment.destroy unless self.payment.nil?
      self.save
    end


    private

    def subscribe_customer
      Subscriber.create(email: self.customer_email)
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