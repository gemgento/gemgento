require 'shopify_api'

module Gemgento::Adapter::Shopify
  class Category

    # Import all Shopify collections.
    #
    # @return [void]
    def self.import
      page = 1
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url
      shopify_collections = ShopifyAPI::CustomCollection.where(limit: 250, page: page)
      while shopify_collections.any?
        shopify_collections.each do |collection|
          sync_shopify_category(collection)
        end

        page = page + 1
        shopify_collections = ShopifyAPI::CustomCollection.where(limit: 250, page: page)
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
        category = Gemgento::Category.new
      end

      category = Gemgento::Category.find_or_initialize_by(url_key: collection.handle)
      category.name = collection.title
      category.parent = Gemgento::Category.root
      category.image = URI.parse(collection.image) if collection.has_attribute? :image
      category.is_active = collection.published
      category.include_in_menu = false
      category.stores = Gemgento::Store.all
      category.sync_needed = true
      category.save

      Gemgento::Adapter::ShopifyAdapter.create_association(category, collection)

      return category
    end

  end
end