require 'shopify_api'

# Magento attributes that must exist:
# vendor (brand)
# fulfillment_service
# barcode
# option1,2,3.....


module Gemgento::Adapter::Shopify
  class Product

    # Import products from Shopify to Gemgento.
    #
    # @return [void]
    def self.import
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url

      ShopifyAPI::Product.all.each do |product|
        simple_products = []

        if product.attributes[:variants].count > 1
          product.attributes[:variants].each do |variant|
            simple_products << create_simple_product(product, variant, false)
          end

          create_configurable_product(product, simple_products)
        else
          create_simple_product(product, product.attributes[:variants].first, true)
        end
      end
    end

    # Create a simple product from Shopify product data.
    #
    # @param base_product [ShopifyAPI::Product]
    # @param variant [ShopifyAPI::Variant]
    # @param is_catalog_visible [Boolean]
    # @return [Gemgento::Product]
    def self.create_simple_product(base_product, variant, is_catalog_visible)
      product = initialize_product(base_product, variant[:sku], 'simple', is_catalog_visible)
      product.set_attribute_value('barcode', variant[:barcode])
      product.set_attribute_value('compare_at_price', variant[:compare_at_price])
      product.set_attribute_value('fulfillment_service', variant[:fulfillment_service])
      product.set_attribute_value('weight', variant[:grams])
      product.set_attribute_value('price', variant[:price])
      product.set_attribute_value('name', "#{self.name} - #{variant[:title]}")
      product.sync_needed = false
      product.save

      product = set_option_values(product, variant)
      product = set_categories(product, base_product[:id])

      product.sync_needed = true
      product.save

      Gemgento::Adapter::ShopifyAdapter.create_association(product, variant) if product.shopify_adapter.nil?
      product = create_assets(product, base_product[:image], base_product[:images])

      return product
    end

    # Create a simple product from Shopify product data.
    #
    # @param base_product [ShopifyAPI::Product]
    # @param simple_products [Array(Gemgento::Product)]
    # @return [Gemgento::Product]
    def self.create_configurable_product(base_product, simple_products)
      product = initialize_product(base_product, "#{simple_products.first.sku}_configurable", 'configurable', true)
      product.set_attribute_value('barcode', simple_products.first.barcode)
      product.set_attribute_value('compare_at_price', simple_products.firstcompare_at_price)
      product.set_attribute_value('fulfillment_service', simple_products.first.fulfillment_service)
      product.set_attribute_value('weight', simple_products.first.weight)
      product.set_attribute_value('price', simple_products.first.price)
      product.simple_products = simple_products
      product.sync_needed = false
      product.save

      product = set_configurable_attributes(product, base_product[:variants].first)
      product = set_categories(product, base_product[:id])

      product.sync_needed = true
      product.save

      Gemgento::Adapter::ShopifyAdapter.create_association(product, base_product) if product.shopify_adapter.nil?
      product = create_assets(product, base_product[:image], base_product[:images])

      return product
    end

    # Initialize a Gemgento::Product given some basic data form Shopify product.
    #
    # @param base_product [ShopifyAPI::Product]
    # @param sku [String]
    # @param magento_type [String]
    # @param is_catalog_visible [Boolean]
    # @return [Gemgento::Product]
    def self.initialize_product(base_product, sku, magento_type, is_catalog_visible)
      product = Gemgento::Product.not_deleted.find_or_initialize_by(sku: sku)
      product.magento_type = magento_type
      product.visibility = is_catalog_visible ? 4 : 1
      product.set_attribute_value('url_key', base_product[:handle])
      product.set_attribute_value('name', base_product[:title])
      product.set_attribute_value('vendor', base_product[:vendor])
      product.set_attribute_value('meta-keywords', base_product[:tags])
      product.stores = Gemgento::Store.all

      return product
    end

    # Set product attribute values that have options.
    #
    # @param product [Gemgento::Product]
    # @param variant [ShopifyAPI::Variant]
    # @return [Gemgento::Product]
    def self.set_option_values(product, variant)
      variant.each do |key, value|
        if key.to_s.include? 'option'
          product.set_attribute_value(key, value)
        end
      end

      product.sync_needed = false
      product.save

      return product
    end

    # Associate product with categories based on Shopify collections.
    #
    # @param product [Gemgento::Product]
    # @param shopify_id [Integer]
    # @return [Gemgento::Product]
    def self.set_categories(product, shopify_id)
      collections = ShopifyAPI::CustomCollection.where(product_id: shopify_id)

      Gemgento::Adapter::ShopifyAdapter.where(shopify_model: collections).each do |shopify_adapter|
        category = shopify_adapter.gemgento_model

        Gemgento::Store.all.each do |store|
          product_category = Gemgento::ProductCategory.find_or_initialize_by(product: product, category: category, store: store)
          product_category.sycn_needed = false
          product_category.save
        end
      end

      product.product_categories.reload

      return product
    end

    # Define the configurable attributes for a configurable product.
    #
    # @param product [Gemgento::Product]
    # @param variant [ShopifyAPI::Variant]
    # @return [Gemgento::Product]
    def self.set_configurable_attributes(product, variant)
      variant.each do |key, value|
        if key.to_s.include? 'option'
          attribute = Gemgento::ProductAttribute.find_by(code: key)

          if attribute.is_configurable
            product.configurable_attributes << attribute unless product.configurable_attributes.include? attribute
          end
        end
      end

      product.sync_needed = false
      product.save

      return product
    end

    # Create the assets for a product.
    #
    # @param product [Gemgento::Product]
    # @param base_image [ShopifyAPI::Image]
    # @param images [Array(ShopifyAPI::Image)]
    # @return [Gemgento::Product]
    def self.create_assets(product, base_image, images)
      images.each do |image|
        asset = Gemgento::Asset.find_or_initialize_by(product: product, label: image.id)
        asset.asset_types << Gemgento::AssetType.find_by(code: 'image') if image == base_image
        asset.set_file(URI.parse(source[:url]))
        asset.store = product.stores.first
        asset.position = image.position
        asset.sync_needed = false
        asset.save

        asset.sync_needed = true
        asset.save

        Gemgento::Adapter::ShopifyAdapter.create_association(asset, image)
      end

      return product
    end


  end
end