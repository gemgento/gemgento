module Gemgento
  module API
    module SOAP
      module Catalog
        class Category

          # Pull all Magento Category into Gemgento.
          #
          # @return [Void]
          def self.fetch_all
            Store.all.each do |store|
              response = tree(store)
              if response.success?
                sync_magento_tree_to_local(response.body[:tree], store) unless response.body[:tree].nil?
              end
            end
          end

          # Get the Category tree from Magento.
          #
          # @param store [Gemgento::Store]
          # @return [Gemgento::MagentoResponse]
          def self.tree(store)
            message = {
                store_view: store.magento_id
            }
            MagentoApi.create_call(:catalog_category_tree, message)
          end

          # Get Category info from Magento.
          #
          # @param magento_id [Integer] Magento category id.
          # @param store [Gemgento::Store]
          # @return [Gemgento::MagentoResponse]
          def self.info(magento_id, store)
            message = {
                category_id: magento_id,
                store_view: store.magento_id
            }
            MagentoApi.create_call(:catalog_category_info, message)
          end

          # Create Category in Magento.
          #
          # @param category [Gemgento::Category]
          # @param store [Gemgento::Store]
          # @return [Gemgento::MagentoResponse]
          def self.create(category, store)
            data = {
                name: category.name,
                'is_active' => category.is_active ? 1 : 0,
                'include_in_menu' => category.include_in_menu ? 1 : 0,
                'available_sort_by' => {'arr:string' => %w[name]},
                'default_sort_by' => 'name',
                'url_key' => category.url_key,
                'position' => category.position,
                'is_anchor' => 1
            }
            message = {
                parentId: category.parent.magento_id,
                category_data: data,
                store_view: store.magento_id
            }
            MagentoApi.create_call(:catalog_category_create, message)
          end

          def self.update(category, store)
            data = {
                name: category.name,
                'is_active' => category.is_active ? 1 : 0,
                'include_in_menu' => category.include_in_menu ? 1 : 0,
                'url_key' => category.url_key,
                'position' => category.position
            }
            message = {
                category_id: category.magento_id,
                category_data: data,
                store_view: store.magento_id
            }
            MagentoApi.create_call(:catalog_category_update, message)
          end

          # Update Category Product positions in Magento.
          #
          # @param category [Gemgento::Category]
          # @param store [Gemgento::Store]
          # @return [Gemgento::MagentoResponse]
          def self.update_product_positions(category, store)
            # create an array of product positions
            product_positions = []
              category.product_categories.where(store: store).each do |product_category|
              next if product_category.category.nil? or product_category.product.nil? or !product_category.product.deleted_at.nil?

              product_positions << {
                  product_id: product_category.product.magento_id,
                  position: product_category.position
              }
            end

            message = {
                category_id: category.magento_id,
                product_positions: {item: product_positions},
                store_id: store.magento_id
            }

            MagentoApi.create_call(:catalog_category_update_product_positions, message)
          end

          # Get Products assigned to a Category in Magento.
          #
          # @param category [Gemgento::Category]
          # @param store [Gemgento::Store]
          # @return [Gemgento::MagentoResponse]
          def self.assigned_products(category, store)
            message = {
                category_id: category.magento_id,
                store_id: store.magento_id
            }
            response = MagentoApi.create_call(:catalog_category_assigned_products, message)

            if response.success?
              if response.body[:result][:item].nil?
                response.body[:result][:item] = []
              elsif !response.body[:result][:item].is_a? Array
                response.body[:result][:item] = [response.body[:result][:item]]
              end
            end

            return response
          end

          # Update all Category Products based on Magento data.
          #
          # @return [Void]
          def self.set_product_categories
            ::Gemgento::Category.all.each do |category|

              category.stores.each do |store|
                response = assigned_products(category, store)
                next unless response.success?

                items = response.body[:result][:item]

                if items.nil? || items == false || items.empty?
                  ProductCategory.unscoped.where(category: category, store: store).destroy_all
                  next
                end

                product_category_ids = []
                items.each do |item|
                  product = ::Gemgento::Product.find_by(magento_id: item[:product_id])
                  next if product.nil?

                  pairing = ProductCategory.unscoped.find_or_initialize_by(category: category, product: product, store: store)
                  pairing.position = item[:position].nil? ? 1 : item[:position][0]
                  pairing.store = store
                  pairing.save

                  product_category_ids << pairing.id
                end

                ProductCategory.unscoped.
                    where('store_id = ? AND category_id = ? AND id NOT IN (?)', store.id, category.id, product_category_ids).
                    destroy_all
              end
            end
          end

          # Update ProductCategory info in Magento.
          #
          # @param product_category [Gemgento::ProductCategory]
          # @return [Gemgento::MagentoResponse]
          def self.update_product(product_category)
            message = {
                category_id: product_category.category.magento_id,
                product: product_category.product.magento_id,
                position: product_category.position,
                product_identifier_type: 'id'
            }
            MagentoApi.create_call(:catalog_category_update_product, message)
          end

          private

          # Traverse Magento category tree while synchronizing with local category tree
          #
          # @param category_tree [Hash] The returned item of Magento API call
          # @param store [Gemgento::Store]
          # @return [Void]
          def self.sync_magento_tree_to_local(category_tree, store)
            response = info(category_tree[:category_id], store)

            if response.success?
              sync_magento_to_local(response.body[:info], store)

              if category_tree[:children][:item]
                category_tree[:children][:item] = [category_tree[:children][:item]] unless category_tree[:children][:item].is_a? Array
                category_tree[:children][:item].each do |child|
                  sync_magento_tree_to_local(child, store)
                end
              end
            end
          end

          # Synchronize the response of a catalogCategoryInfo API call to local database
          #
          # @param subject [Hash] The returned item of Magento API call
          # @param store [Gemgento::Store]
          # @return [Void]
          def self.sync_magento_to_local(subject, store)
            category = ::Gemgento::Category.find_or_initialize_by(magento_id: subject[:category_id])
            category.name = subject[:name]
            category.url_key = subject[:url_key]
            category.parent = ::Gemgento::Category.find_by(magento_id: subject[:parent_id])
            category.position = subject[:position]
            category.is_active = subject[:is_active]
            category.include_in_menu = subject[:include_in_menu].to_i == 1 ? true : false
            category.all_children = subject[:all_children].nil? ? '' : subject[:all_children]

            if subject.key? :image
              begin
                category.image = open("#{Config[:magento][:url]}/media/catalog/category/#{subject[:image]}")
              rescue
                category.image = nil
              end
            end

            category.sync_needed = false
            category.save

            category.stores << store unless category.stores.include?(store)
          end
        end
      end
    end
  end
end