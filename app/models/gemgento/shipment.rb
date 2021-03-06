module Gemgento

  # @author Gemgento LLC
  class Shipment < ActiveRecord::Base
    belongs_to :order, class_name: 'Gemgento::Order'

    has_many :shipment_comments, class_name: 'Gemgento::ShipmentComment', dependent: :destroy
    has_many :shipment_items, class_name: 'Gemgento::ShipmentItem', dependent: :destroy
    has_many :shipment_tracks, class_name: 'Gemgento::ShipmentTrack', dependent: :destroy

    attr_accessor :email, :comment, :include_comment

    def send_email
      API::SOAP::Sales::OrderShipment.send_info(self.increment_id)
    end

    def as_json(options = nil)
      result = super
      result['items'] = self.shipment_items
      result['comments'] = self.shipment_comments
      result['tracks'] = self.shipment_tracks

      return result
    end

    def push_to_magento
      increment_id = API::SOAP::Sales::OrderShipment.create(self)

      if increment_id == false
        return false
      else
        self.increment_id = increment_id
        self.save
      end
    end

  end
end