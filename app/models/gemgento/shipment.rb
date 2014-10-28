module Gemgento
  class Shipment < ActiveRecord::Base
    belongs_to :order

    has_many :shipment_comments
    has_many :shipment_items
    has_many :shipment_tracks

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

    def email
      @email || 0
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