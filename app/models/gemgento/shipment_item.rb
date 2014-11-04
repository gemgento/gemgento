module Gemgento

  # @author Gemgento LLC
  class ShipmentItem < ActiveRecord::Base
    belongs_to :shipment
    belongs_to :line_item
  end
end