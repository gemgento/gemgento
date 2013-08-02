require 'spreadsheet'

module Gemgento
  class ProductImport
=begin
Pre-requisites:
-Column headers match attribute codes
-There is only one attribute set, or the needed attribute set is the first one
-All needed attributes already belong to the attribute set

Assumptions
-'Collections' is the parent category of the 'parent_category' column
-'Collections' already exists
-Only 'child_category' is assigned to product
-Two assets are created from one image
-Products are grouped by SKU
=end

    def initialize(file, store_view = 1, root_category_id = 2, configurable_attributes = [], image_prefix = '', image_suffix = '', image_labels = nil, attribute_set_id)
      @worksheet = Spreadsheet.open(file).worksheet(0)
      @headers = get_headers
      @messages = []
      @associated_simple_products = []
      @image_prefix = image_prefix
      @image_suffix = image_suffix
      @image_labels = image_labels
      @attribute_set = Gemgento::ProductAttributeSet.find(attribute_set_id) # assuming there is only one product attribute set
      @root_category = Gemgento::Category.find(root_category_id)
      @store_view = store_view
      @configurable_attributes = configurable_attributes
    end

    def process
      1.upto @worksheet.last_row_index do |index|
        puts "Working on row #{index}"
        @row = @worksheet.row(index)

        if @row[@headers.index('magento_type')].to_s.casecmp('simple') == 0
          @associated_simple_products << create_simple_product
        else
          create_configurable_product
        end
      end

      puts @messages
    end

    private

    def get_headers
      accepted_headers = []

      @worksheet.row(0).each do |h|
        accepted_headers << h.downcase.gsub(' ', '_')
      end

      accepted_headers
    end

    def create_simple_product
      # Decide how to format skus - for now use suffix of size column
      sku = @row[@headers.index('sku')].to_s.strip

      product = Gemgento::Product.find_by(sku: sku)

      if product.nil? # If product isn't known locally, check with Magento
        product = Gemgento::Product.check_magento(sku, 'sku', @attribute_set)
      end

      product.magento_type = 'simple'
      product.sku = sku
      product.product_attribute_set = @attribute_set

      unless product.magento_id
        product.sync_needed = false
        product.save
      end

      set_attribute_values(product)
      set_categories(product)
      product.store = Gemgento::Store.first
      product.sync_needed = true
      product.save

      set_image(product)

      product
    end

    def set_attribute_values(product)
      @headers.each do |attribute_code|
        product_attribute = Gemgento::ProductAttribute.find_by(code: attribute_code) # try to load attribute associated with column header

        # apply the attribute value if the attribute exists and is part of the attribute set or default attribute set
        if !product_attribute.nil? && product_attribute.code != 'sku'
          if product_attribute.product_attribute_options.empty?
            value = @row[@headers.index(attribute_code)]
          else # attribute value may have to be associated with an attribute option id
            attribute_option = Gemgento::ProductAttributeOption.find_by(product_attribute_id: product_attribute.id, label: @row[@headers.index(attribute_code)])

            if attribute_option.nil?
              attribute_option = create_attribute_option(product_attribute, @row[@headers.index(attribute_code)])
            end

            value = attribute_option.value
          end

          product.set_attribute_value(product_attribute.code, value)
        end
      end

      set_default_attribute_values(product)
    end

    def create_attribute_option(product_attribute, option_label)
      attribute_option = Gemgento::ProductAttributeOption.new
      attribute_option.product_attribute = product_attribute
      attribute_option.label = option_label
      attribute_option.save

      attribute_option.sync_local_to_magento
      attribute_option.reload

      attribute_option
    end

    def set_default_attribute_values(product)
      product.set_attribute_value('url_key', product.attribute_value('name').sub(' ', '-').downcase) if product.attribute_value('url_key').blank?
      product.set_attribute_value('status', '1') if product.attribute_value('status').blank?
      product.set_attribute_value('visibility', '4') if product.attribute_value('visibility').blank?
    end

    def set_categories(product)
      categories = @row[@headers.index('category')].split('&')

      categories.each do |category_string|
        subcategories = category_string.split('>')

        subcategories.each do |category_url_key|
          category = Gemgento::Category.find_by(url_key: category_url_key)

          unless category.nil?
            product.categories << category unless product.categories.include?(category)
          else
            @messages << "ERROR - row #{@row.index} - Unknown category url key '#{category_url_key}' - skipped"
          end
        end
      end
    end

    def set_image(product)
      product.assets.destroy_all

      images_found = []
      # find the correct image file name and path
      @image_labels.each_with_index do |label, position|
        file_name = @image_prefix + @row[@headers.index('image')] + '_' + label + @image_suffix
        next unless File.exist?(file_name)
        images_found << file_name

        types = Gemgento::AssetType.find_by(product_attribute_set: @attribute_set)

        unless types.is_a? Array
          types = [types]
        end

        product.assets << create_image(product, file_name, types, position, label)
      end

      if images_found.empty?
        @messages << "WARNING: No images found for id:#{product.id}, sku: #{product.sku}"
      end
    end

    def create_image(product, file_name, types, position, label)
      image = Gemgento::Asset.new
      image.product = product
      image.attachment = File.open(file_name)
      image.position = position
      image.label = label

      types.each do |type|
        image.asset_types << type
      end

      image.sync_needed = false
      image.save

      image.sync_needed = true
      image.save

      image
    end

    def create_configurable_product
      sku = @row[@headers.index('sku')].to_s.strip

      # set the default configurable product attributes
      configurable_product = Gemgento::Product.where(sku: sku).first_or_initialize

      configurable_product.magento_type = 'configurable'
      configurable_product.sku = sku
      configurable_product.product_attribute_set = @attribute_set
      configurable_product.sync_needed = false
      configurable_product.store = Gemgento::Store.first
      configurable_product.save

      # associate all simple products with the new configurable product
      @associated_simple_products.each do |simple_product|
        configurable_product.simple_products << simple_product unless configurable_product.simple_products.include?(simple_product)
      end

      # add the configurable attributes
      @configurable_attributes.each do |configurable_attribute|
        configurable_product.configurable_attributes << configurable_attribute unless configurable_product.configurable_attributes.include?(configurable_attribute)
      end

      # set the additional configurable product details
      set_attribute_values(configurable_product)
      set_categories(configurable_product)

      # push to magento
      configurable_product.sync_needed = true
      configurable_product.save

      # add the images
      set_configurable_product_images(configurable_product)

      # clear the simple products
      @associated_simple_products.clear
    end

    def set_configurable_product_images(configurable_product)
      configurable_product.assets.destroy_all
      default_product = configurable_product.simple_products.first

      default_product.assets.each do |asset|
        asset_copy = Gemgento::Asset.new
        asset_copy.product = configurable_product
        asset_copy.attachment = File.open(asset.attachment.path(:original))
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