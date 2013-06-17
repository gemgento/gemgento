module Gemgento
  class Inventory < ActiveRecord::Base
    belongs_to :product

    def self.index
      if Inventory.find(:all).size == 0
        API::SOAP::CatalogInventory::StockItem.fetch_all
      end

      Inventory.find(:all)
    end

  end
end