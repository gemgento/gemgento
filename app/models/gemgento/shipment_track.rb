module Gemgento
  class ShipmentTrack < ActiveRecord::Base
    belongs_to :shipment
    belongs_to :order
  end
end