module Gemgento
  class Inventory < ActiveRecord::Base
    belongs_to :product

    after_save :touch_product

    def self.index
      if Inventory.all.size == 0
        API::SOAP::CatalogInventory::StockItem.fetch_all
      end

      Inventory.all
    end

    def push
      Gemgento::API::SOAP::CatalogInventory::StockItem.update(self.product);
    end

    def in_stock?(quantity)
      if self.is_in_stock || quantity.to_f <= self.quantity.to_f
        return true
      else
        return false
      end
    end

    private

    def touch_product
      Gemgento::Product.skip_callback(:save, :after, :sync_local_to_magento)
      self.product.update(updated_at: Time.now) if self.changed?
      Gemgento::Product.set_callback(:save, :after, :sync_local_to_magento)
    end

  end
end