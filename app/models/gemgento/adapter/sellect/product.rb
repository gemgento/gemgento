module Gemgento::Adapter::Sellect
  class Product < ActiveRecord::Base
    establish_connection("sellect_#{Rails.env}".to_sym)

    def self.import
      #TODO: Unmapped attributes - color, hex_color, available_on, tax_category_id, shipping_category_id, on_sale, sale_price, model_name, size_pictured, product_details, count_on_hand, style_color, is_representative_color, season_id
      self.table_name = 'sellect_products'

      self.all.each do |sellect_product|
        product = Gemgento::Product.find_or_initialize_by(sku: sellect_product.sku)
        product.magento_type = 'configurable'
        product.sku = sellect_product.sku
        product.status = sellect_product.is_private
        product.set_attribute_value('name', sellect_product.name)
        product.set_attribute_value('short_description', sellect_product.description)
        product.set_attribute_value('url_key', sellect_product.permalink)
        product.set_attribute_value('meta_description', sellect_product.meta_description)
        product.set_attribute_value('meta_keywords', sellect_product.meta_keywords)
        product.set_attribute_value('description', sellect_product.detail_description)
        product.set_attribute_value('style_code', sellect_product.style)
        product.sync_needed = false
        product.save

        import_variants(sellect_product.id, product)
        import_assets(sellect_product.id, product)

        # push configurable product to Magento
        product.sync_needed = true
        product.save
      end
    end

    def self.import_variants(sellect_id, configurable_product)
      self.table_name = 'sellect_variants'

      self.where('product_id = ?', sellect_id).each do |sellect_variant|
        product = Gemgento::Product.find_or_initialize_by(sku, sellect_variant.sku)
        product.magento_type = 'simple'
        product.sku = sellect_variant.sku
        product.status = configurable_product.is_private
        product.set_attribute_value('name', configurable_product.name)
        product.set_attribute_value('short_description', configurable_product.description)
        product.set_attribute_value('url_key', configurable_product.permalink)
        product.set_attribute_value('meta_description', configurable_product.meta_description)
        product.set_attribute_value('meta_keywords', configurable_product.meta_keywords)
        product.set_attribute_value('description', configurable_product.detail_description)
        product.set_attribute_value('style_code', configurable_product.style)
        product.set_attribute_value('upc', sellect_variant.upc)
        product.configurable_product = configurable_product
        product.sync_needed = false
        product.save

        set_option_values(sellect_variant.id, product)
        import_assets(sellect_variant.id, product)

        product.sync_needed = true
        product.save
      end
    end

    def set_option_value(sellect_id, product)
      self.table_name = 'sellect_option_types'

      self.all.each do |option|
        attribute = Gemgento::ProductAttribute.find_by(code: option.name.downcase)
        label = option_label(option, sellect_id)
        attribute_option = Gemgento::ProductAttributeOption.find_by(product_attribute_id: attribute.id, label: label)

        if attribute_option.nil?
          attribute_option = create_attribute_option(attribute, label)
        end

        product.set_attribute_value(attribute.code, attribute_option.value)
        product.sync_needed = false
        product.save
      end
    end

    def self.option_label(option, sellect_id)
      option_value = query('sellect_option_values').joins(ActiveRecord::Base.escape_sql(
                                                              'INNER JOIN sellect_option_values_variants ON sellect_option_values_variants.option_value_id = sellect_option_values.id ' +
                                                                  'AND sellect_option_values.option_type_id = ? AND sellect_option_values_variants.variant_id = ?',
                                                              option.id
                                                          )).first

      return option_value.name
    end

    def self.create_attribute_option(product_attribute, option_label)
      attribute_option = ProductAttributeOption.new
      attribute_option.product_attribute = product_attribute
      attribute_option.label = option_label
      attribute_option.store = Gemgento::Store.current
      attribute_option.sync_needed = false
      attribute_option.save

      attribute_option.sync_needed = true
      attribute_option.sync_local_to_magento
      attribute_option.destroy

      return Gemgento::ProductAttributeOption.where(product_attribute: product_attribute, label: option_label, store: self.store).first
    end

    def self.import_assets(sellect_id, product)
      #TODO: Import assets
    end
  end
end