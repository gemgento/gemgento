module Gemgento
  class LineItem < ActiveRecord::Base
    belongs_to :itemizable, polymorphic: true, touch: true
    belongs_to :product

    validates :itemizable, :product, presence: true

    before_save :push_magento_quote_item, if: "itemizable_type == 'Gemgento::Quote' && !async"
    after_save :push_magento_quote_item_async, if: "itemizable_type == 'Gemgento::Quote' && async"
    before_destroy :destroy_magento_quote_item

    serialize :options, Hash

    attr_accessor :async

    def as_json(options = nil)
      result = super
      result['product'] = self.product.as_json({ store: Store.find(self.itemizable.store.id) })
      return result
    end

    private

    def push_magento_quote_item
      if new_record?
        response = API::SOAP::Checkout::Product.add(itemizable, [self])
      else
        response = API::SOAP::Checkout::Product.update(itemizable, [self])
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
        Cart::AddItemWorker.perform_async(self.id)
      else
        Cart::UpdateItemWorker.perform_async(self.id, self.qty_itemizableed_was)
      end
    end

    def destroy_magento_quote_item
      response = API::SOAP::Checkout::Product.remove(itemizable, [self])

      if response.success?
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

  end
end