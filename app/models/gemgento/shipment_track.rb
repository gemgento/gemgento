module Gemgento

  # @author Gemgento LLC
  class ShipmentTrack < ActiveRecord::Base
    belongs_to :shipment
    belongs_to :order

    attr_accessor :sync_needed

    before_create :push_to_magento, if: :sync_needed

    def push_to_magento
      return API::SOAP::Sales::OrderShipment.add_track(self)
    end
  end
end