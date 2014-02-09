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
                products: { item: product_ids },
            }
            response = Gemgento::Magento.create_call(:catalog_inventory_stock_item_list, message)

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

            response = Gemgento::Magento.create_call(:catalog_inventory_stock_item_update, message)

            return response.success?
          end

          private

          # Save Magento users inventory to local
          def self.sync_magento_to_local(source)
            product = Gemgento::Product.unscoped.find_by(magento_id: source[:product_id])
            return false if product.nil?

            if source[:stock].nil? # multiple inventory extension not present
              Gemgento::Store.all.each do |store|
                create_inventory_from_magento(product, source, store)
              end
            else # multiple inventories present
              source[:stock][:item].each do |store_stock|
                puts(store_stock).inspect
                store = Gemgento::Store.find_by(website_id: store_stock[:website_id].to_i)
                create_inventory_from_magento(product, store_stock, store)
              end
            end
          end

          def self.create_inventory_from_magento(product, source, store)
            inventory = Gemgento::Inventory.where(product: product, store: store).first_or_initialize
            inventory.store = store
            inventory.product = product
            inventory.quantity = source[:qty].is_a?(Array) ? source[:qty][0] : source[:qty]
            inventory.is_in_stock = source[:is_in_stock]
            inventory.sync_needed = false
            inventory.use_default_website_stock = source[:use_default_website_stock].nil? ? true : source[:use_default_website_stock]
            inventory.save
          end

          def self.compose_inventory_data(inventory)
            data = {
                qty: inventory.quantity.to_s,
                'is_in_stock' => inventory.is_in_stock ? 1 : 0,
                'manage_stock' => 1,
                'use_default_website_stock' => inventory.use_default_website_stock ? 1 : 0
            }

            if !inventory.use_default_website_stock
              data[:website_id] = inventory.store.website_id
            end

            return data
          end

        end
      end
    end
  end
end