module Gemgento
  class Inventory < ActiveRecord::Base
    belongs_to :product
    belongs_to :store

    after_save :touch_product, :sync_local_to_magento

    def self.index
      if Inventory.all.size == 0
        API::SOAP::CatalogInventory::StockItem.fetch_all
      end

      Inventory.all
    end

    def push
      Gemgento::API::SOAP::CatalogInventory::StockItem.update(self.product);
    end

    def in_stock?(quantity = 1)
      puts "#{quantity.to_f} <= #{self.quantity}"
      if self.is_in_stock && (quantity.to_f <= self.quantity.to_f || quantity.to_f == 0)
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

    # Push local product changes to magento
    def sync_local_to_magento
      if self.sync_needed
        API::SOAP::CatalogInventory::StockItem.update(self)

        self.sync_needed = false
        self.save
      end
    end

  end
end