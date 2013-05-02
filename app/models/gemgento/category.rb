module Gemgento
  class Category < ActiveRecord::Base
    has_many :assets

    def self.index
      if Category.find(:all).size == 0
        fetch_all
      end
      Category.find(:all)
    end

    # Synchronize local database with Magento database
    def self.fetch_all
      category_response = Gemgento::Magento.create_call(:catalog_category_tree)

      # Root Category is the first thing always returned, so no need to cycle through the response
      traverse_tree_and_create(category_response.body[:catalog_category_tree_response][:tree])
    end

    # Create the category and traverse it's children
    #
    # @param [Hash] category  The returned item of Magento API call
    def self.traverse_tree_and_create(category)
        # TODO: create/update the category
        if category[:children][:item]
          category[:children][:item].each do |child|
            traverse_tree_and_create(child)
          end
        end
    end
  end
end