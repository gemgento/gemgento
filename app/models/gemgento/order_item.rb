module Gemgento
  class OrderItem < ActiveRecord::Base
    belongs_to :order, touch: true
    belongs_to :product

    def as_json(options = nil)
      result = super
      result['product'] = self.product
      return result
    end
  end
end