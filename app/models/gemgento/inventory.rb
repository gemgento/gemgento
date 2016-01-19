module Gemgento

  # @author Gemgento LLC
  class Inventory < ActiveRecord::Base
    include Gemgento::ProductTouches

    belongs_to :product, class_name: 'Gemgento::Product'
    belongs_to :store, class_name: 'Gemgento::Store'

    # Inventory.backorder may have one of the following values:
    # 0 - no backorders
    # 1 - allow qty below 0
    # 2 - allow qty below 0 and notify customer
    validates :backorders, inclusion: 0..2
    validates :product, uniqueness: { scope: :store }

    before_save :sync_local_to_magento, if: -> { sync_needed? }

    attr_accessor :use_config_manage_stock

    # Push the inventory data to Magento.
    #
    # @return [Boolean] true if the inventory data was successfully pushed to Magento
    def push
      API::SOAP::CatalogInventory::StockItem.update(self.product);
    end

    # Determine if the specified quantity is in stock.
    #
    # @param quantity [Integer] the required quantity
    # @return [Boolean] true if the required quantity is in stock
    def in_stock?(quantity = 1)
      if !self.manage_stock?
        return true
      elsif self.is_in_stock && ((quantity.to_f <= self.quantity.to_f || quantity.to_f == 0) || self.backorders > 0)
        return true
      else
        return false
      end
    end

    private

    # Push local inventory changes to magento.
    #
    # @return [Void]
    def sync_local_to_magento
      response = API::SOAP::CatalogInventory::StockItem.update(self)

      if response.success?
        self.sync_needed = false
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

  end
end