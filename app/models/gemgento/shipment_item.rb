module Gemgento
  class ShipmentItem < ActiveRecord::Base
    belongs_to :shipment
    belongs_to :product
  end
end