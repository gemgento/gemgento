require 'shopify_api'

module Gemgento::Adapter::Shopify
  class ProductCategoryPosition

    # Set all product category positions based on Shopify collects
    #
    # @return [Void]
    def self.set_all
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url

      @collections = ShopifyAPI::CustomCollection.all
      @collects = ShopifyAPI::Collect.all

      @collects.each do |collect|
        collection = @collections.select { |c| c.id = collect.collection_id }.first
        category = Gemgento::Category.find_by(url_key: collection.handle)
        product = Gemgento::Product.filter(
            {
                attribute: Gemgento::ProductAttribute.find_by(code: 'shopify_id'),
                value: collect.product_id
            }
        ).first

        set_product_category_position(product, category, collect.position)
      end

      push_all_positions
    end

    # Set product category positions for each store.
    #
    # @param product [Gemgento::Product]
    # @param category [Gemgento::Category]
    # @param position [Integer]
    # @return [Void]
    def self.set_product_category_position(product, category, position)
      Gemgento::Store.all.each do |store|
        product_category = Gemgento::ProductCategory.find_by(product: product, category: category, store: store)
        product_category.position = position
        product_category.sync_needed = false
        product_category.save
      end
    end

    # Push all product category positions to Magento
    #
    # @return [Void]
    def self.push_all_positions
      Gemgento::Category.all.each do |category|
        Gemgento::Store.all.each do |store|
          Gemgento::API::SOAP::Catalog::Category.update_product_positions(category, store)
        end
      end
    end

  end
end