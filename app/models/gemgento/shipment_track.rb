module Gemgento
  class ShipmentTrack < ActiveRecord::Base
    belongs_to :shipment
    belongs_to :order

    before_create :push_to_magento

    private

    def push_to_magento
      return API::SOAP::Sales::OrderShipment.add_track(self)
    end
  end
end