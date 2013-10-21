module Gemgento
  module API
    module SOAP
      module CatalogInventory
        class StockItem

          def self.fetch_all(products = nil)
            products = Gemgento::Product.all if products.nil?
            magento_product_ids = []

            products.each do |product|
              magento_product_ids << product.magento_id
            end

            list(magento_product_ids).each do |inventory|
              begin
                sync_magento_to_local(inventory)
              rescue
                'unknown error'
                # TODO: solve - NameError: undefined local variable or method `x' for #<Gemgento::Product:0x007ff280bbb370>
              end
            end
          end

          def self.list(product_ids)
            response = Gemgento::Magento.create_call(:catalog_inventory_stock_item_list, {products: {item: product_ids}})

            if response.success?
              if response.body[:result][:item].nil?
                response.body[:result][:item] = []
              end

              unless response.body[:result][:item].is_a? Array
                response.body[:result][:item] = [response.body[:result][:item]]
              end

              response.body[:result][:item]
            end
          end

          def self.update(product)
            message = {
                product: product.magento_id,
                data: compose_inventory_data(product.inventory)
            }

            response = Gemgento::Magento.create_call(:catalog_inventory_stock_item_update, message)

            return response.success?
          end

          private

          # Save Magento users inventory to local
          def self.sync_magento_to_local(source)
            product = Gemgento::Product.where(magento_id: source[:product_id]).first_or_initialize
            inventory = Gemgento::Inventory.where(product: product).first_or_initialize
            inventory.product = product
            inventory.quantity = source[:qty]
            inventory.is_in_stock = source[:is_in_stock]
            inventory.sync_needed = false
            inventory.save
          end

          def self.compose_inventory_data(inventory)
            {
                qty: inventory.quantity.to_s,
                'is_in_stock' => inventory.is_in_stock ? 1 : 0,
                'manage_stock' => 1
            }
          end

        end
      end
    end
  end
end