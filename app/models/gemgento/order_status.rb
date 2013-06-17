module Gemgento
  class OrderStatus < ActiveRecord::Base
    belongs_to :order
  end
end