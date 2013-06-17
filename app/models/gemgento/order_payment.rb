module Gemgento
  class OrderPayment < ActiveRecord::Base
    belongs_to :order
  end
end