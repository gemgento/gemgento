module Gemgento

  # @author Gemgento LLC
  class RecurringProfile < ActiveRecord::Base

    belongs_to :user
    belongs_to :store
    has_and_belongs_to_many :orders, class_name: 'Gemgento::Order', join_table: 'gemgento_orders_recurring_profiles'

    validates :magento_id, uniqueness: true, presence: true

    serialize :order_info, Hash
    serialize :order_item_info, Hash
    serialize :billing_address_info, Hash
    serialize :shipping_address_info, Hash
    serialize :profile_vendor_info, Hash
    serialize :additional_info, Hash

    scope :active, -> { where(state: 'active') }
    scope :suspended, -> { where(state: 'suspended') }
    scope :canceled, -> { where(state: 'canceled') }

    def change_state(state)
      Gemgento::API::SOAP::Sales::RecurringProfile.update_state(self.magento_id, state)
    end

  end
end