module Gemgento
  class Shipment < ActiveRecord::Base
    belongs_to :order

    has_many :shipment_comments
    has_many :shipment_items
    has_many :shipment_tracks

    before_create :push_to_magento, unless: :increment_id

    def send_email
      Gemgento::API::SOAP::Sales::OrderShipment.send_info(self.increment_id)
    end

    def as_json(options = nil)
      result = super
      result['comments'] = self.shipment_comments
      result['tracks'] = self.shipment_tracks

      return result
    end

    private

    def push_to_magento
      increment_id = Gemgento::API::SOAP::Sales::OrderShipment.create(self.order.increment_id)

      if increment_id == false
        return false
      else
        self.increment_id = increment_id
      end
    end
  end
end