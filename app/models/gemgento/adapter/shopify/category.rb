require 'shopify_api'

module Gemgento::Adapter::Shopify
  class Category

    # Import all Shopify collections.
    #
    # @return [void]
    def import
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url

      ShopifyAPI::CustomCollection.all.each do |collection|
        sync_shopify_category(collection)
      end
    end

    # Create Gemgento::Category from Shopify collection.
    #
    # @param collection [ShopifyAPI::CustomCollection]
    # @return [Gemgento::Category]
    def sync_shopify_category(collection)
      category = Gemgento::Category.find_or_initialize_by(url_key: collection.handle)
      category.name = collection.title
      category.parent_id = Gemgento::Category.root
      category.image = URI.parse(collection.image) if collection.image
      category.is_active = true
      category.include_in_menu = false
      category.sync_needed = category.new_record?
      category.save

      Gemgento::Adapter::ShopifyAdapter.create_association(category, collection)

      return category
    end

  end
end