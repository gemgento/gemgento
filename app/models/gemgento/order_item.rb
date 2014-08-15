module Gemgento
  class OrderItem < ActiveRecord::Base
    belongs_to :order, touch: true
    belongs_to :product

    serialize :options, Hash

    def as_json(options = nil)
      result = super
      result['product'] = self.product.as_json({ store: Gemgento::Store.find(self.order.store.id) })
      return result
    end
  end
end