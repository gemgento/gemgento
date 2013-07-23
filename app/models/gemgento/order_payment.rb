module Gemgento
  class OrderPayment < ActiveRecord::Base
    belongs_to :order

    attr_accessor :cc_number
  end
end