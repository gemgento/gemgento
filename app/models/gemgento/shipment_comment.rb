module Gemgento
  class ShipmentTrack < ActiveRecord::Base
    belongs_to :shipment
  end
end