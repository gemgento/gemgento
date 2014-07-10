require 'shopify_api'

module Gemgento::Adapter::Shopify
  class Category

    # Import all Shopify collections.
    #
    # @return [void]
    def self.import
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url

      ShopifyAPI::CustomCollection.all.each do |collection|
        sync_shopify_category(collection)
      end
    end

    # Create Gemgento::Category from Shopify collection.
    #
    # @param collection [ShopifyAPI::CustomCollection]
    # @return [Gemgento::Category]
    def self.sync_shopify_category(collection)
      if shopify_adapter = Gemgento::Adapter::ShopifyAdapter.find_by_shopify_model(collection)
        category = shopify_adapter.gemgento_model
      else
        category = Gemgento::Category.find_or_initialize_by(url_key: collection.handle)
      end

      category = Gemgento::Category.find_or_initialize_by(url_key: collection.handle)
      category.name = collection.title
      category.parent = Gemgento::Category.root
      category.image = URI.parse(collection.image) if collection.has_attribute? :image
      category.is_active = true
      category.include_in_menu = false
      category.stores = Gemgento::Store.all
      category.sync_needed = true
      category.save

      Gemgento::Adapter::ShopifyAdapter.create_association(category, collection)

      return category
    end

  end
end