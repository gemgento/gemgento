module Gemgento

  # @author Gemgento LLC
  class OrderStatus < ActiveRecord::Base
    belongs_to :order
  end
end