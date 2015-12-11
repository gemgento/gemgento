module Gemgento

  # @author Gemgento LLC
  class ShipmentTrack < ActiveRecord::Base
    belongs_to :shipment, class_name: 'Gemgento::Shipment'

    has_one :order, through: :shipment, class_name: 'Gemgento::Order'

    attr_accessor :sync_needed

    before_create :push_to_magento, if: :sync_needed

    def push_to_magento
      return API::SOAP::Sales::OrderShipment.add_track(self)
    end

    def tracking_url
      "https://www.google.com/search?q=#{self.number}"
    end
  end
end