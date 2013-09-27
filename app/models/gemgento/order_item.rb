module Gemgento
  class OrderItem < ActiveRecord::Base
    belongs_to :order, touch: true
    belongs_to :product
    has_one :gift_message
  end
end