module Gemgento
  class Category < ActiveRecord::Base
    has_many :assets
    after_save :sync_local_to_magento

    def self.index
      if Category.find(:all).size == 0
        fetch_all
      end
      Category.find(:all)
    end

    # Synchronize local database with Magento database
    def self.fetch_all
      category_response = Gemgento::Magento.create_call(:catalog_category_tree)

      # Root node is the response
      sync_magento_tree_to_local(category_response.body[:catalog_category_tree_response][:tree])
    end

    private

    # Traverse Magento category tree while synchronizing with local category tree
    #
    # @param [Hash] category  The returned item of Magento API call
    def self.sync_magento_tree_to_local(category)
      category_response = Gemgento::Magento.create_call(:catalog_category_info, { categoryId: category[:category_id] })
      sync_magento_to_local(category_response.body[:catalog_category_info_response][:info])

        if category[:children][:item]
          category[:children][:item].each do |child|
            sync_magento_tree_to_local(child)
          end
        end
    end

    # Synchronize the response of a catalogCategoryInfo API call to local database
    #
    # @param [Hash] subject The returned item of Magento API call
    def self.sync_magento_to_local(subject)
      category = Category.find_or_initialize_by_magento_id(subject[:category_id])
      category.magento_id = subject[:category_id]
      category.name = subject[:name]
      category.url_key = subject[:url_key]
      category.parent_id = subject[:parent_id]
      category.position = subject[:position]
      category.is_active = subject[:is_active]
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
    def sync_local_to_magento
      if self.sync_needed
        if !self.magento_id
         puts here
         exit
          create_magento
        else
          update_magento
        end

        self.sync_needed = false
        self.save
      end
    end

    # Create a new Magento Category
    def create_magento
      category_data = {
          name: self.name,
          is_active: self.is_active,
          available_sort_by: %w[name],
          default_sort_by: %w[name]
      }
      message = {parentId: self.parent_id, categoryData: category_data}
      create_response = Gemgento::Magento.create_call(:catalog_category_create, message)
      puts create_response.body
      exit
    end

    # Update existing Magento Category
    def update_magento
    end
  end
end