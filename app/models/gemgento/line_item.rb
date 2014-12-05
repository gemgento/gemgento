module Gemgento

  # @author Gemgento LLC
  class LineItem < ActiveRecord::Base
    belongs_to :itemizable, polymorphic: true, touch: true
    belongs_to :product

    validates :itemizable, :product, presence: true
    validates_with InventoryValidator, if: -> { itemizable_type == 'Gemgento::Quote' }

    before_save :push_magento_quote_item, if: -> { itemizable_type == 'Gemgento::Quote' && !async.to_bool }
    after_save :push_magento_quote_item_async, if: -> { itemizable_type == 'Gemgento::Quote' && async.to_bool }
    before_destroy :destroy_magento_quote_item, if: -> { itemizable_type == 'Gemgento::Quote' }

    serialize :options, Hash

    attr_accessor :async

    # JSON representation of the LineItem.
    #
    # @param options [Hash]
    # @return [Void]
    def as_json(options = nil)
      result = super
      result['product'] = self.product.as_json({ store: Store.find(self.itemizable.store.id) })
      return result
    end

    private

    # Create or Update the associated Magento Quote Item.
    #
    # @return [Boolean]
    def push_magento_quote_item
      if new_record?
        response = API::SOAP::Checkout::Product.add(itemizable, [self])
      else
        response = API::SOAP::Checkout::Product.update(itemizable, [self])
      end

      if response.success?
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    # Create or Update the associated Magento Quote Item asynchronously.
    #
    # @return [Void]
    def push_magento_quote_item_async
      if new_record?
        Cart::AddItemWorker.perform_async(self.id)
      else
        Cart::UpdateItemWorker.perform_async(self.id, self.qty_ordered_was)
      end
    end

    # Destroy the associated Magento Quote Item.
    #
    # @return [Boolean]
    def destroy_magento_quote_item
      response = API::SOAP::Checkout::Product.remove(itemizable, [self])

      if response.success?
        return true
      else
        handle_magento_response(response)
        return false
      end
    end

    def handle_magento_response(response)
      if response.body[:faultcode].to_i == 1002 && itemizable_type == 'Gemgento::Quote' # quote doesn't exist in Magento.
        LineItem.skip_callback(:destroy, :before, :destroy_magento_quote_item)
        self.itemizable.destroy
        LineItem.set_callback(:destroy, :before, :destroy_magento_quote_item)
      else
        self.errors.add(:base, response.body[:faultstring])
      end
    end

  end
end