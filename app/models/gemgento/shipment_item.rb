module Gemgento

  # @author Gemgento LLC
  class ShipmentItem < ActiveRecord::Base
    belongs_to :shipment, class_name: 'Gemgento::Shipment'
    belongs_to :line_item, class_name: 'Gemgento::LineItem'

    has_one :order, through: :shipment, class_name: 'Gemgento::Order'
    has_one :product, through: :line_item, class_name: 'Gemgento::Product'
  end
end