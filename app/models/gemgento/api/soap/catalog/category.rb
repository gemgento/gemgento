module Gemgento
  module API
    module SOAP
      module Catalog
        class Category

          # Synchronize local database with Magento database
          def self.fetch_all
            Gemgento::Store.all.each do |store|
              category_tree = tree(store)
              sync_magento_tree_to_local(category_tree, store) unless category_tree.nil?
            end
          end

          def self.tree(store)
            message = {
              store_view: store.magento_id
            }
            response = Gemgento::Magento.create_call(:catalog_category_tree, message)

            if response.success?
              return response.body[:tree]
            end
          end

          def self.info(category_id, store)
            message = {
                category_id: category_id,
                store_view: store.magento_id
            }
            response = Gemgento::Magento.create_call(:catalog_category_info, message)

            if response.success?
              return response.body[:info]
            end
          end

          def self.create(category)
            data = {
                name: self.name,
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
            response = Gemgento::Magento.create_call(:catalog_category_create, message)

            if response.success?
              category.magento_id = response.body[:attribute_id]
              category.sync_needed = false
              category.save
            end
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
            response = Gemgento::Magento.create_call(:catalog_category_update, message)
            response.body
          end

          def self.update_product_positions(category, store)
            # create an array of product positions
            product_positions = []
            Gemgento::Product.unscoped do
              category.product_categories.where(store: store).each do |product_category|
                next unless product_category.product.deleted_at.nil?

                product_positions << {
                    product_id: product_category.product.magento_id,
                    position: product_category.position
                }
              end
            end

            # compose the message body
            message = {
                category_id: category.magento_id,
                product_positions: {item: product_positions},
                store_id: store.magento_id
            }

            # make the call
            response = Gemgento::Magento.create_call(:catalog_category_update_product_positions, message)

            return response.success?
          end

          def self.assigned_products(category, store)
            message = {
                category_id: category.magento_id,
                store_id: store.magento_id
            }
            response = Gemgento::Magento.create_call(:catalog_category_assigned_products, message)

            if response.success? && !response.body[:result][:item].nil?
              result = response.body[:result][:item]
              result = [result] unless result.is_a? Array

              return result
            else
              return false
            end
          end

          def self.set_product_categories
            Gemgento::Category.all.each do |category|

              category.stores.each do |store|
                result = assigned_products(category, store)

                if result.nil? || result == false || result.empty?
                  Gemgento::ProductCategory.unscoped.where(category: category, store: store).destroy_all
                  next
                end

                product_category_ids = []
                result.each do |item|
                  product = Gemgento::Product.find_by(magento_id: item[:product_id])
                  next if product.nil?

                  pairing = Gemgento::ProductCategory.unscoped.find_or_initialize_by(category: category, product: product, store: store)
                  pairing.position = item[:position].nil? ? 1 : item[:position][0]
                  pairing.store = store
                  pairing.save

                  product_category_ids << pairing.id
                end

                Gemgento::ProductCategory.unscoped.
                    where('store_id = ? AND category_id = ? AND id NOT IN (?)', store.id, category.id, product_category_ids).
                    destroy_all
              end
            end
          end

          def self.update_product(product_category)
            message = {
                category_id: product_category.category.magento_id,
                product: product_category.product.magento_id,
                position: product_category.position,
                product_identifier_type: 'id'
            }
            response = Gemgento::Magento.create_call(:catalog_category_update_product, message)

            if response.success?
              return response.body[:info]
            end
          end

          private

          # Traverse Magento category tree while synchronizing with local category tree
          #
          # @param [Hash] category_tree  The returned item of Magento API call
          def self.sync_magento_tree_to_local(category_tree, store)
            sync_magento_to_local(info(category_tree[:category_id], store), store)

            if category_tree[:children][:item]
              category_tree[:children][:item] = [category_tree[:children][:item]] unless category_tree[:children][:item].is_a? Array
              category_tree[:children][:item].each do |child|
                sync_magento_tree_to_local(child, store)
              end
            end
          end

          # Synchronize the response of a catalogCategoryInfo API call to local database
          #
          # @param [Hash] subject The returned item of Magento API call
          def self.sync_magento_to_local(subject, store)
            category = Gemgento::Category.where(magento_id: subject[:category_id]).first_or_initialize
            category.magento_id = subject[:category_id]
            category.name = subject[:name]
            category.url_key = subject[:url_key]
            category.parent = Gemgento::Category.find_by(magento_id: subject[:parent_id])
            category.position = subject[:position]
            category.is_active = subject[:is_active]
            category.include_in_menu = subject[:include_in_menu].to_i == 1 ? true : false
            category.all_children = subject[:all_children].nil? ? '' : subject[:all_children]

            if subject.key? :image
              begin
                category.image = open("http://#{Gemgento::Config[:magento][:url]}/media/catalog/category/#{subject[:image]}")
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