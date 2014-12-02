module Gemgento

  # @author Gemgento LLC
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

    attr_accessor :tax, :total, :push_cart_customer, :subscribe

    validates :customer_email, format: /@/, allow_nil: true
    validates :status, presence: true

    after_save :mark_quote_converted, if: -> { quote && quote.converted_at.nil? && !state.blank? }

    # Return the increment_id instead of id.  This is for privacy purposes.
    #
    # @return [String]
    def to_param
      self.increment_id
    end

    # Set associated quote converted_at.
    #
    # @return [Void]
    def mark_quote_converted
      quote.update(converted_at: Time.now)
    end

  end
end