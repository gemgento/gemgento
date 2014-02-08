module Gemgento
  class Shipment < ActiveRecord::Base
    belongs_to :order
  end
end