module Gemgento
  class OrderStatusHistory < ActiveRecord::Base
    belongs_to :order
  end
end