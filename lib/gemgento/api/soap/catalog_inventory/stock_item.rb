module Gemgento
  module API
    module SOAP
      module CatalogInventory
        class StockItem

          def self.fetch_all(products = nil)
            products = Gemgento::Product.simple.not_deleted if products.nil?
            magento_product_ids = []

            products.each do |product|
              magento_product_ids << product.magento_id
            end

            list(magento_product_ids).each do |inventory|
              sync_magento_to_local(inventory)
            end
          end

          def self.list(product_ids)
            message = {
                products: {item: product_ids},
            }
            response = Gemgento::MagentoApi.create_call(:catalog_inventory_stock_item_list, message)

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

          def self.update(inventory)
            message = {
                product: inventory.product.magento_id,
                data: compose_inventory_data(inventory)
            }

            return Gemgento::MagentoApi.create_call(:catalog_inventory_stock_item_update, message)
          end

          private

          # Save Magento users inventory to local
          def self.sync_magento_to_local(source)
            product = Gemgento::Product.unscoped.find_by(magento_id: source[:product_id])
            return false if product.nil?

            Store.all.each do |store|
              create_inventory_from_magento(product, source, store)
            end
          end

          def self.create_inventory_from_magento(product, source, store)
            inventory = Gemgento::Inventory.find_or_initialize_by(product: product, store: store)
            inventory.quantity = source[:qty].is_a?(Array) ? source[:qty][0] : source[:qty]
            inventory.is_in_stock = source[:is_in_stock]
            inventory.sync_needed = false
            inventory.save
          end

          def self.compose_inventory_data(inventory)
            data = {
                qty: inventory.quantity.to_s,
                'is_in_stock' => inventory.is_in_stock ? 1 : 0,
                'manage_stock' => inventory.manage_stock ? 1 : 0,
                'use_config_manage_stock' => 0,
                backorders: inventory.backorders,
                'use_config_backorders' => inventory.use_config_backorders ? 1 : 0,
                'min_qty' => inventory.min_qty,
                'use_config_min_qty' => inventory.use_config_min_qty ? 1 : 0
            }

            return data
          end

        end
      end
    end
  end
end