module Gemgento
  class Shipment < ActiveRecord::Base
    belongs_to :order

    has_many :shipment_comments
    has_many :shipment_items
    has_many :shipment_tracks

    after_create :push_to_magento

    attr_accessor :include_in_email

    def send_email
      comment = Gemgento::ShipmentComment.new
      comment.shipment = self
      comment.comment = 'Sending shipment email from Gemgento'
      comment.is_customer_notified = true
      comment.include_in_email = false
      comment.save
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