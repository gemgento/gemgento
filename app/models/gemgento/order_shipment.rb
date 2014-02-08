module Gemgento
  class OrderShipment < ActiveRecord::Base
    belongs_to :order
  end
end