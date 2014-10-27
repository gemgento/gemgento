module Gemgento
  class OrderItem < ActiveRecord::Base
    belongs_to :order, touch: true
    belongs_to :product

    validates :order, :product, presence: true

    before_save :push_magento_quote_item, if: "order.state == 'cart' && !async"
    after_save :push_magento_quote_item_async, if: "order.state == 'cart' && async"
    before_destroy :destroy_magento_quote_item

    serialize :options, Hash

    attr_accessor :async

    def as_json(options = nil)
      result = super
      result['product'] = self.product.as_json({ store: Gemgento::Store.find(self.order.store.id) })
      return result
    end

    private

    def push_magento_quote_item
      if new_record?
        response = API::SOAP::Checkout::Product.add(order, [self])
      else
        response = API::SOAP::Checkout::Product.update(order, [self])
      end

      if response.success?
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    def push_magento_quote_item_async
      if new_record?
        Gemgento::Cart::AddItemWorker.perform_async(self.id)
      else
        Gemgento::Cart::UpdateItemWorker.perform_async(self.id, self.qty_ordered_was)
      end
    end

    def destroy_magento_quote_item
      response = API::SOAP::Checkout::Product.remove(order, [self])

      if response.success?
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

  end
end