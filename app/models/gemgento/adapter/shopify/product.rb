require 'shopify_api'

# Magento attributes that must exist:
# vendor (brand)
# fulfillment_service
# barcode
# compare_at_price
# option1,2,3.....


module Gemgento::Adapter::Shopify
  class Product

    # Import products from Shopify to Gemgento.
    #
    # @return [void]
    def self.import
      page = 1
      ShopifyAPI::Base.site = Gemgento::Adapter::ShopifyAdapter.api_url
      shopify_products = ShopifyAPI::Product.where(limit: 250, page: page)

      while shopify_products.any?
        shopify_products.each do |product|
          simple_products = []

          if product.variants.count > 1
            product.variants.each do |variant|
              simple_products << create_simple_product(product, variant, false)
            end

            create_configurable_product(product, simple_products)
          else
            create_simple_product(product, product.variants.first, true)
          end
        end

        page = page + 1
        shopify_products = ShopifyAPI::Product.where(limit: 250, page: page)
      end

      push_tags
    end

    # Create a simple product from Shopify product data.
    #
    # @param base_product [ShopifyAPI::Product]
    # @param variant [ShopifyAPI::Variant]
    # @param is_catalog_visible [Boolean]
    # @return [Gemgento::Product]
    def self.create_simple_product(base_product, variant, is_catalog_visible)
      product = initialize_product(base_product, variant.sku, 'simple', is_catalog_visible)
      product.set_attribute_value('barcode', variant.barcode)
      product.set_attribute_value('compare_at_price', variant.compare_at_price)
      product.set_attribute_value('fulfillment_service', variant.fulfillment_service)
      product.set_attribute_value('weight', variant.grams)
      product.set_attribute_value('price', variant.price)

      if is_catalog_visible # catalog visible simple products are not part of a configurable
        product.set_attribute_value('name', base_product.title)
      else
        product.set_attribute_value('name', "#{base_product.title} - #{variant.title}")
      end

      product = set_option_values(product, base_product, variant)
      product = set_categories(product, base_product.id)

      product.sync_needed = true
      product.save

      Gemgento::Adapter::ShopifyAdapter.create_association(product, variant) if product.shopify_adapter.nil?
      product = create_assets(product, base_product.image, base_product.images)
      create_tags(product, base_product.tags)
      create_inventory(product, variant)

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
      product.set_attribute_value('compare_at_price', simple_products.first.compare_at_price)
      product.set_attribute_value('fulfillment_service', simple_products.first.fulfillment_service)
      product.set_attribute_value('weight', simple_products.first.weight)
      product.set_attribute_value('price', simple_products.first.price)
      product.set_attribute_value('name', base_product.title)

      simple_products.uniq.each do |simple_product|
        simple_product.configurable_products << product unless simple_product.configurable_products.include? product
      end

      product.sync_needed = false
      product.save

      product = set_configurable_attributes(product, base_product, base_product.variants.first)
      product = set_categories(product, base_product.id)

      product.sync_needed = true
      product.save

      Gemgento::Adapter::ShopifyAdapter.create_association(product, base_product) if product.shopify_adapter.nil?
      product = create_assets(product, base_product.image, base_product.images)
      create_tags(product, base_product.tags)

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
      if shopify_adapter = Gemgento::Adapter::ShopifyAdapter.find_by_shopify_model(base_product)
        product = shopify_adapter.gemgento_model
      else
        product = Gemgento::Product.not_deleted.find_or_initialize_by(sku: sku)
      end

      product.magento_type = magento_type
      product.visibility = is_catalog_visible ? 4 : 1
      product.product_attribute_set = Gemgento::ProductAttributeSet.first
      product.sync_needed = false
      product.save

      product.set_attribute_value('url_key', base_product.handle)
      product.set_attribute_value('name', base_product.title)
      product.set_attribute_value('vendor', base_product.vendor)
      product.set_attribute_value('meta-keywords', base_product.tags)
      product.stores = Gemgento::Store.all

      return product
    end

    # Set product attribute values that have options.
    #
    # @param product [Gemgento::Product]
    # @param base_product [ShopifyAPI::Product]
    # @param variant [ShopifyAPI::Variant]
    # @return [Gemgento::Product]
    def self.set_option_values(product, base_product, variant)
      variant.attributes.each do |key, value|
        if key.to_s.include? 'option'
          code = get_option_attribute_code(base_product, key)
          next if code.nil?

          value = 'N/A' if value.blank?
          product.set_attribute_value(code, value)
        end
      end

      product.sync_needed = false
      product.save

      return product
    end

    # Get the Gemgento::Attribute.code relate to an Shopify option code.
    #
    # @param base_product [ShopifyAPI::Product]
    # @param option_code [String]
    def self.get_option_attribute_code(base_product, option_code)
      index = option_code.to_s.gsub('option', '').to_i - 1
      return nil if index >= base_product.options.length
      return base_product.options[index].name.downcase
    end

    # Associate product with categories based on Shopify collections.
    #
    # @param product [Gemgento::Product]
    # @param shopify_id [Integer]
    # @return [Gemgento::Product]
    def self.set_categories(product, shopify_id)
      collections = ShopifyAPI::CustomCollection.where(product_id: shopify_id)

      Gemgento::Adapter::ShopifyAdapter.where(shopify_model_type: collections.first.class, shopify_model_id: collections.map(&:id)).each do |shopify_adapter|
        category = shopify_adapter.gemgento_model

        Gemgento::Store.all.each do |store|
          product_category = Gemgento::ProductCategory.find_or_initialize_by(product: product, category: category, store: store)
          product_category.sync_needed = false
          product_category.save
        end
      end

      product.product_categories.reload

      return product
    end

    # Define the configurable attributes for a configurable product.
    #
    # @param product [Gemgento::Product]
    # @param base_product [ShopifyAPI::Product]
    # @param variant [ShopifyAPI::Variant]
    # @return [Gemgento::Product]
    def self.set_configurable_attributes(product, base_product, variant)
      variant.attributes.each do |key, value|
        if key.to_s.include? 'option'
          code = get_option_attribute_code(base_product, key)
          next if code.nil?
          attribute = Gemgento::ProductAttribute.find_by(code: code)

          if attribute && attribute.is_configurable && is_configurable_attribute_used(product, attribute)
            product.configurable_attributes << attribute unless product.configurable_attributes.include? attribute
          end
        end
      end

      product.sync_needed = false
      product.save

      return product
    end

    # Check if a configurable attribute is actually being used to differentiate simples.
    #
    # @param product [Gemgento::Product]
    # @param attribute [Gemgento::ProductAttribute]
    # @return [Boolean]
    def self.is_configurable_attribute_used(product, attribute)
      product.simple_products.each do |simple_product|
        return false unless simple_product.product_attribute_values.exists?(product_attribute: attribute)
      end

      return true
    end

    # Create the assets for a product.
    #
    # @param product [Gemgento::Product]
    # @param base_image [ShopifyAPI::Image]
    # @param images [Array(ShopifyAPI::Image)]
    # @return [Gemgento::Product]
    def self.create_assets(product, base_image, images)
      images.each do |image|
        asset_file = nil

        product.stores.each do |store|
          asset = Gemgento::Asset.find_or_initialize_by(product: product, label: image.id)
          asset.asset_types << Gemgento::AssetType.find_by(code: 'image') if image == base_image
          asset.store = store
          asset.position = image.position
          asset.set_file(URI.parse(image.src))
          asset.sync_needed = false
          asset.save

          asset.sync_needed = true
          asset.save

          asset_file = asset.asset_file
        end

        Gemgento::Adapter::ShopifyAdapter.create_association(asset_file, image) unless asset_file.nil?
      end

      return product
    end

    # Create the inventory for the product.
    #
    # @param product [Gemgento::Product]
    # @param variant [ShopifyAPI::Variant]
    def self.create_inventory(product, variant)
      product.stores.each do |store|
        inventory = Gemgento::Inventory.find_or_initialize_by(product: product, store: store)
        inventory.quantity = variant.inventory_quantity
        inventory.is_in_stock = (inventory.quantity > 0 || variant.inventory_policy == 'continue')
        inventory.backorders = variant.inventory_policy == 'continue' ? 1 : 0
        inventory.sync_needed = inventory.new_record? || inventory.changed?
        inventory.save
      end
    end

    # Create and associate product with tags.
    #
    # @param product [Gemgento::Product]
    # @param tags [String]
    # @return [Void]
    def self.create_tags(product, tags)
      tags.split(',').each do |tag_name|
        tag = Gemgento::Tag.find_or_initialize_by(name: tag_name.strip)
        tag.status = 1
        tag.sync_needed = false
        tag.save

        Gemgento::Store.all.each do |store|
          next if tag.stores.include? store
          tag.store_tags.create(store: store)
        end

        tag.products << product unless tag.products.include? product
        tag.sync_needed = false
        tag.save
      end
    end

    # Push all tags to Magento.
    #
    # @return [Void]
    def self.push_tags
      Gemgento::Tag.all.each do |tag|
        tag.sync_needed = true
        tag.save
      end
    end

  end
end