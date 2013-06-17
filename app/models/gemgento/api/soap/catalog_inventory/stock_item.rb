module Gemgento
  module API
    module SOAP
      module CatalogInventory
        class StockItem

          def self.fetch_all
            products_ids = []
            Product.find(:all).each do |product|
              products_ids << product.magento_id
            end

            list(product_ids).each do |inventory|
                sync_magento_to_local(inventory)
            end
          end

          def self.list(product_ids)
            response = Gemgento::Magento.create_call(:catalog_inventory_stock_item_list, { products: product_ids })

            unless response[:result][:item].nil?
              unless response[:result][:item].is_a? Array
                response[:result][:item] = [response[:result][:item]]
              end
            else
              response[:result][:item] = []
            end

            response[:result][:item]
          end

          def self.update
            #TODO: Create update API call
          end

          private

          # Save Magento user inventory to local
          def self.sync_magento_to_local(source)
            product = Gemgento::Product.find_or_initialize_by(magento_id: source[:product_id])
            inventory = Gemgento::Inventory.find_or_initialize_by(product: product)
            inventory.product = product
            inventory.quantity = source[:qty]
            inventory.is_in_stock = source[:is_in_stock]
            inventory.sync_needed = false
            inventory.save
          end

        end
      end
    end
  end
end