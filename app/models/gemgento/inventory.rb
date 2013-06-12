module Gemgento
  class Inventory < ActiveRecord::Base
    belongs_to :product

    def self.index
      if Inventory.find(:all).size == 0
        fetch_all
      end

      Inventory.find(:all)
    end

    def self.fetch_all
      products_ids = []
      Product.find(:all).each do |product|
        products_ids << product.magento_id
      end

      message = {
          products: { item: products_ids }
      }
      puts message.inspect
      response = Gemgento::Magento.create_call(:catalog_inventory_stock_item_list, message)
      puts response.inspect
      unless response[:result][:item].nil?
        unless response[:result][:item].is_a? Array
          response[:result][:item] = [response[:result][:item]]
        end

        response[:result][:item].each do |inventory|
          sync_magento_to_local(inventory)
        end
      end
    end

    private

    # Save Magento user inventory to local
    def self.sync_magento_to_local(source)
      product = Product.find_or_initialize_by(magento_id: source[:product_id])
      inventory = Inventory.find_or_initialize_by(product: product)
      inventory.product = product
      inventory.quantity = source[:qty]
      inventory.is_in_stock = source[:is_in_stock]
      inventory.sync_needed = false
      inventory.save
    end
  end
end