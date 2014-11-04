module Gemgento

  # @author Gemgento LLC
  class ShipmentComment < ActiveRecord::Base
    belongs_to :shipment

    before_create :push_to_magento

    private

    def push_to_magento
      API::SOAP::Sales::OrderShipment.add_comment(
          self,
          (self.is_customer_notified ? 1 : nil),
          (self.include_in_email ? 1 : nil)
      )
    end
  end
end