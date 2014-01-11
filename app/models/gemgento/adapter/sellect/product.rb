module Gemgento::Adapter::Sellect
  class Product < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym) if Gemgento::Config[:sellect]

    def self.import(currency = 'usd', app_root = '/Users/Kevin/Sites/victoria_beckham_sites/vb_old/')
      #TODO: Unmapped attributes - color, hex_color, available_on, tax_category_id, shipping_category_id, on_sale, sale_price, model_name, size_pictured, product_details, count_on_hand, style_color, is_representative_color, season_id
      self.table_name = 'sellect_products'

      self.where('deleted_at IS NULL').each do |sellect_product|
        product = Gemgento::Product.active.find_or_initialize_by(sku: sellect_product.sku, magento_type: 'configurable')

        product.magento_type = 'configurable'
        product.sku = sellect_product.sku
        product.status = sellect_product.is_private
        product.product_attribute_set = Gemgento::ProductAttributeSet.first
        product.visibility = 4
        product.sync_needed = false
        product.save

        product.set_attribute_value('name', sellect_product.name)
        product.set_attribute_value('short_description', sellect_product.description)
        product.set_attribute_value('url_key', sellect_product.permalink)
        product.set_attribute_value('meta_description', sellect_product.meta_description)
        product.set_attribute_value('meta_keyword', sellect_product.meta_keywords)
        product.set_attribute_value('description', sellect_product.detail_description)
        product.set_attribute_value('style_code', sellect_product.style)

        set_categories(sellect_product.id, product)

        simple_products = import_simple_products(sellect_product.id, product, app_root, currency)

        if simple_products.size <= 1 # if one or less simple products, the configurable is not needed
          product.destroy
        else # configurable is needed, set configurable attrbitues and simple products
          set_configurable_attribute(product, 'size')
          set_configurable_attribute(product, 'color')

          simple_products.each do |simple_product|
            product.simple_products << simple_product unless product.simple_products.include?(simple_product)
          end

          product.sync_needed = true
          product.save

          create_configurable_images(product)
        end
      end
    end

    def self.import_simple_products(sellect_id, configurable_product, app_root, currency = 'usd')
      self.table_name = 'sellect_variants'

      simple_products = []
      upc = Gemgento::ProductAttribute.find_by(code: 'upc')
      raise "Missing required product attribute 'UPC'" if upc.nil?

      sellect_variants = self.where('product_id = ?', sellect_id)

      sellect_variants.each do |sellect_variant|
        product = Gemgento::Product.where(magento_type: 'simple').filter({ attribute: upc, value: sellect_variant.upc }).first_or_initialize
        product.magento_type = 'simple'
        product.status = configurable_product.status
        product.product_attribute_set = configurable_product.product_attribute_set
        product.set_attribute_value('name', configurable_product.name)
        product.set_attribute_value('short_description', configurable_product.description)
        product.set_attribute_value('url_key', configurable_product.url_key)
        product.set_attribute_value('meta_description', configurable_product.meta_description)
        product.set_attribute_value('meta_keyword', configurable_product.meta_keyword)
        product.set_attribute_value('description', configurable_product.description)
        product.set_attribute_value('style_code', configurable_product.style_code)
        product.set_attribute_value('upc', sellect_variant.upc)
        product.set_attribute_value('weight', sellect_variant.weight.nil? ? 0 : sellect_variant.weight)
        product.categories = configurable_product.categories
        product.visibility = sellect_variants.size > 1 ? 1 : 4
        product.sync_needed = false
        product.save

        set_option_values(sellect_variant.id, product)
        set_price(sellect_variant.id, product, currency)

        product.sku = "#{sellect_variant.sku}_#{product.size}"

        product.sync_needed = true
        product.save

        set_assets(sellect_variant, product, app_root)

        simple_products << product
      end

      return simple_products
    end

    def self.set_option_values(sellect_id, product)
      self.table_name = 'sellect_option_types'

      self.all.each do |option|
        attribute = Gemgento::ProductAttribute.find_by(code: option.name.downcase)
        label = get_option_label(option, sellect_id)
        label = '' if label.nil?

        attribute_option = Gemgento::ProductAttributeOption.find_by(product_attribute_id: attribute.id, label: label)

        if attribute_option.nil?
          attribute_option = create_attribute_option(attribute, label)
        end

        product.set_attribute_value(attribute.code, attribute_option.value)
        product.sync_needed = false
        product.save
      end
    end

    def self.get_option_label(option, variant_id)
      self.table_name = 'sellect_option_values'
      option_value = self.joins(ActiveRecord::Base.escape_sql(
                    'INNER JOIN sellect_option_values_variants ON sellect_option_values_variants.option_value_id = sellect_option_values.id ' +
                        'AND sellect_option_values.option_type_id = ? AND sellect_option_values_variants.variant_id = ?',
                    option.id,
                    variant_id
                )).first

      return option_value.name
    end

    def self.create_attribute_option(product_attribute, option_label)
      attribute_option = Gemgento::ProductAttributeOption.new
      attribute_option.product_attribute = product_attribute
      attribute_option.label = option_label
      attribute_option.store = Gemgento::Store.current
      attribute_option.sync_needed = false
      attribute_option.save

      attribute_option.sync_needed = true
      attribute_option.sync_local_to_magento
      attribute_option.destroy

      return Gemgento::ProductAttributeOption.where(product_attribute: product_attribute, label: option_label).first
    end

    def self.set_assets(sellect_product, gemgento_product, app_root)
      self.inheritance_column = :_type_disabled
      self.table_name = 'sellect_assets'

      self.where(viewable_id: sellect_product.id, viewable_type: 'Sellect::Variant').each do |sellect_asset|
        file = "#{app_root}/public/system/assets/products/#{sellect_asset.id}/original/#{sellect_asset.attachment_file_name}"

        if File.exist?(file)
          image = Gemgento::Asset.new

          gemgento_product.assets.where(store: Gemgento::Store.current).each do |asset|
            if !asset.asset_file.nil? && FileUtils.compare_file(asset.asset_file.file.path(:original), file)
              image = asset
              break
            end
          end

          image.product = gemgento_product
          image.store = Gemgento::Store.current
          image.position = sellect_asset.position
          image.label = sellect_asset.alt
          image.set_file(File.open(file))
          image.asset_types << Gemgento::AssetType.all
          image.sync_needed = false
          image.save

          image.sync_needed = true
          image.save

          image
        end
      end
    end

    def self.set_price(variant_id, product, currency)
      self.table_name = 'sellect_pricings'

      pricing = self.where('variant_id = ? AND currency LIKE ?', variant_id, currency).first
      return if pricing.nil?

      product.set_attribute_value('price', pricing.price)
      product.sync_needed = false
      product.save
    end

    def self.set_categories(product_id, product)
      self.table_name = 'sellect_product_categories'

      self.joins(ActiveRecord::Base.escape_sql(
                'INNER JOIN sellect_product_positions ON sellect_product_positions.product_category_id = sellect_product_categories.id ' +
                    'AND sellect_product_positions.product_id = ?',
                product_id
            )).each do |sellect_category|
        categories = Gemgento::Category.where(url_key: sellect_category.permalink)

        categories.each do |category|
          product.categories << category unless product.categories.include? category
        end
      end
    end

    def self.set_configurable_attribute(product, attribute_code)
      attribute = Gemgento::ProductAttribute.find_by(code: attribute_code)
      product.configurable_attributes << attribute unless product.configurable_attributes.include?(attribute)
    end

    def self.create_configurable_images(configurable_product)
      default_product = configurable_product.simple_products.first

      default_product.assets.where(store: Gemgento::Store.current).each do |asset|

        asset_copy = Gemgento::Asset.new

        configurable_product.assets.where(store: Gemgento::Store.current).each do |existing_asset|
          if !existing_asset.asset_file.nil? && FileUtils.compare_file(existing_asset.asset_file.file.path(:original), asset.asset_file.file.path(:original))
            asset_copy = existing_asset
            break
          end
        end

        asset_copy.product = configurable_product
        asset_copy.store = Gemgento::Store.current
        asset_copy.set_file(File.open(asset.asset_file.file.path(:original)))
        asset_copy.label = asset.label
        asset_copy.position = asset.position
        asset_copy.asset_types = asset.asset_types

        asset_copy.sync_needed = false
        asset_copy.save

        asset_copy.sync_needed = true
        asset_copy.save
      end
    end

  end
end