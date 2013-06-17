module Gemgento
  module API
    module SOAP
      module Catalog
        class Category

          # Synchronize local database with Magento database
          def self.fetch_all
            sync_magento_tree_to_local(tree)
          end

          def self.tree
            response = Gemgento::Magento.create_call(:catalog_category_tree)

            unless response[:tree].is_a? Array
              response[:tree] = [response[:tree]]
            end

            response[:tree]
          end

          def self.info(category_id)
            response = Gemgento::Magento.create_call(:catalog_category_info, {
                category_id: category_id
            })
            response[:info]
          end

          def self.create(category)
            data = {
                name: self.name,
                'is_active' => category.is_active ? 1 : 0,
                'include_in_menu' => category.include_in_menu ? 1 : 0,
                'available_sort_by' =>  { 'arr:string' => %w[name] },
                'default_sort_by' => 'name',
                'url_key' => category.url_key,
                'position' => category.position,
                'is_anchor' => 1
            }
            message = {parentId: category.parent_id, categoryData: data}
            response = Gemgento::Magento.create_call(:catalog_category_create, message)

            category.magento_id = response[:attribute_id]
            category.save
          end

          def self.update(category)
            data = {
                name: category.name,
                'is_active' => category.is_active ? 1 : 0,
                'include_in_menu' => category.include_in_menu ? 1 : 0,
                'url_key' => category.url_key,
                'position' => category.position
            }
            message = {categoryId: category.magento_id, categoryData: data}
            Gemgento::Magento.create_call(:catalog_category_update, message)
          end

          private

          # Traverse Magento category tree while synchronizing with local category tree
          #
          # @param [Hash] category  The returned item of Magento API call
          def self.sync_magento_tree_to_local(category)
            sync_magento_to_local(info([:category_id]))

            if category[:children][:item]
              category[:children][:item] = [category[:children][:item]] unless category[:children][:item].is_a? Array
              category[:children][:item].each do |child|
                sync_magento_tree_to_local(child)
              end
            end
          end

          # Synchronize the response of a catalogCategoryInfo API call to local database
          #
          # @param [Hash] subject The returned item of Magento API call
          def self.sync_magento_to_local(subject)
            category = Gemgento::Category.find_or_initialize_by(magento_id: subject[:category_id])
            category.magento_id = subject[:category_id]
            category.name = subject[:name]
            category.url_key = subject[:url_key]
            category.parent_id = subject[:parent_id]
            category.position = subject[:position]
            category.is_active = subject[:is_active]
            category.include_in_menu = subject[:include_in_menu] == 1 ? true : false
            category.children_count = subject[:children_count]

            if category.children_count > 0
              category.all_children = subject[:all_children]
              category.children = subject[:children]
            else
              category.all_children = ''
              category.children = ''
            end

            category.sync_needed = false
            category.save
          end

          # Synchronize the category with Magento
          def self.sync_local_to_magento(category)
            if self.sync_needed
              if !category.magento_id
                self.create(category)
              else
                self.update(category)
              end
            end
          end

        end
      end
    end
  end
end