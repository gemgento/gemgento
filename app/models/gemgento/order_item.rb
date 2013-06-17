module Gemgento
  class OrderItem < ActiveRecord::Base
    belongs_to  :order
    belongs_to  :product
    has_one     :gift_message
  end
end