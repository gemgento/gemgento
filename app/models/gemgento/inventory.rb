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

    private

    def touch_product
      self.product.update(updated_at: Time.now) if self.changed?
    end

  end
end