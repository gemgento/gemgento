module Gemgento
  class Shipment < ActiveRecord::Base
    belongs_to :order

    has_many :shipment_comments
    has_many :shipment_items
    has_many :shipment_tracks
  end
end