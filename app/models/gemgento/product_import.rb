require 'Spreadsheet'

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

    def initialize(file, store_view = 1, image_prefix = '', image_suffix = '', thumbnail_suffix = '', root_category_id = 0)
      @worksheet = Spreadsheet.open(file).worksheet(0)
      @image_prefix = image_prefix
      @image_suffix = image_suffix
      @thumbnail_suffix = thumbnail_suffix
      @headers = get_headers
      @messages = []
      @attribute_of_association = 'style_code'
      @associated_simple_products = {}
      @attribute_set = Gemgento::ProductAttributeSet.first # assuming there is only one product attribute set
      @root_category = Gemgento::Category.find(root_category_id)
      @store_view = store_view
      @configurable_attributes = [
          Gemgento::ProductAttribute.find_by(code: 'color'),
          Gemgento::ProductAttribute.find_by(code: 'measurement')
      ]
    end

    def process
      1.upto @worksheet.last_row_index do |index|
        puts "Working on row #{index}"
        if @worksheet.row(index)[0].nil? || @worksheet.row(index)[1].nil?
          @messages << "Row ##{index} missing sku or name"
          next
        end
        @row = @worksheet.row(index)
        product = create_simple_product
        track_associated_simple_products(product)
        puts @messages
      end

      create_configurable_products

      puts @messages
    end

    private

    def get_headers
      accepted_headers = []

      @worksheet.row(0).each do |h|
        accepted_headers << h.downcase.gsub(' ','_')
      end

      accepted_headers
    end

    def create_simple_product
      sku = @row[@headers.index('sku')].to_s + '-CO'
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

      product.sync_needed = true
      product.save

      set_image(product)

      product
    end

    def set_attribute_values(product)
      @headers.each do |attribute_code|
        product_attribute = Gemgento::ProductAttribute.find_by(code: attribute_code) # try to load attribute associated with column header

        # apply the attribute value if the attribute exists and is part of the attribute set
        if !product_attribute.nil? && @attribute_set.product_attributes.include?(product_attribute) && product_attribute.code != 'sku'

          if product_attribute.product_attribute_options.empty?
            value = @row[@headers.index(attribute_code)]
          else # attribute value may have to be associated with an attribute option id  '
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

      attribute_option
    end

    def set_default_attribute_values(product)
      product.set_attribute_value('url_key', product.attribute_value('name').sub(' ', '-').downcase) if product.attribute_value('url_key').blank?
      product.set_attribute_value('status', '1') if product.attribute_value('status').blank?
      product.set_attribute_value('visibility', '1') if product.attribute_value('visibility').blank?
    end

    def set_categories(product)
      parent_category = Gemgento::Category.find_by(parent_id: @root_category.magento_id, name: @row[@headers.index('category_parent')])

      if parent_category.nil?
        parent_category = create_category(@row[@headers.index('category_parent')], @root_category)
      end

      child_category = Gemgento::Category.find_by(parent_id: parent_category.magento_id, name: @row[@headers.index('category_child')])

      if child_category.nil?
        child_category = create_category(@row[@headers.index('category_child')], parent_category)
      end

      product.categories << parent_category unless product.categories.include?(parent_category)
      product.categories << child_category unless product.categories.include?(child_category)
    end

    def create_category(name, parent_category)
      category = Gemgento::Category.new
      category.parent_id = parent_category.magento_id
      category.name = name
      category.url_key = name.sub(' ', '-').downcase
      category.is_active = 1
      category.save

      category
    end

    def set_image(product)
      product.assets.destroy_all

      # set the main product image
      url = @image_prefix + @row[@headers.index('image')] + @image_suffix
      if File.file?(url)
       types = [Gemgento::AssetType.find_by(code: 'image'), Gemgento::AssetType.find_by(code: 'small_image')]
       product.assets << create_image(product, url, types)
      else
        @messages << "File Missing - #{url}"
      end

      # set the thumbnail image
      url = @image_prefix + @row[@headers.index('image')] + @thumbnail_suffix
      if File.file?(url)
        types = [Gemgento::AssetType.find_by(code: 'thumbnail')]
        product.assets << create_image(product, url, types)
      else
        @messages << "File Missing - #{url}"
      end
    end

    def create_image(product, url, types)
      image = Gemgento::Asset.new
      image.product = product
      image.url = url

      types.each do |type|
        image.asset_types << type
      end

      image.save

      image
    end

    def track_associated_simple_products(product)
      if @associated_simple_products[:"#{product.attribute_value(@attribute_of_association)}"].nil?
        @associated_simple_products[:"#{product.attribute_value(@attribute_of_association)}"] = 1
      else
        @associated_simple_products[:"#{product.attribute_value(@attribute_of_association)}"] += 1
      end
    end

    def create_configurable_products
      @associated_simple_products.each do |attribute_value, count|
        # grab all the simple products that are associated
        simple_products = fetch_associated_products(attribute_value)

        # set the default configurable product attributes
        configurable_product = Gemgento::Product.find_or_initialize_by(sku: "#{attribute_value}-CO")
        next if configurable_product.magento_id
        configurable_product.magento_type = 'configurable'
        configurable_product.sku = "#{attribute_value}-CO"
        configurable_product.product_attribute_set = @attribute_set
        configurable_product.sync_needed = false
        configurable_product.save

        # associate all simple products with the new configurable product
        simple_products.each do |simple_product|
          configurable_product.simple_products << simple_product
        end

        # add the configurable attributes
        # TODO: set configurable attributes array before importing spreadsheet
        @configurable_attributes.each do |configurable_attribute|
          configurable_product.configurable_attributes << configurable_attribute unless configurable_product.configurable_attributes.include?(configurable_attribute)
        end

        configurable_product.set_attribute_value('name', simple_products.first.attribute_value('name'))
        configurable_product.set_attribute_value('status', '1')
        configurable_product.set_attribute_value('visibility', '2')
        configurable_product.set_attribute_value('url_key', configurable_product.attribute_value('name').sub(' ', '-').downcase)

        configurable_product.categories = simple_products.first.categories

        # push to magento
        configurable_product.sync_needed = true
        configurable_product.save

       set_configurable_product_images(configurable_product)
      end
    end

    def fetch_associated_products(attribute_value)
      product_attribute = Gemgento::ProductAttribute.find_by(code: @attribute_of_association)
      product_attribute_values = Gemgento::ProductAttributeValue.where(product_attribute_id: product_attribute.id, value: attribute_value)
      associated_products = []

      product_attribute_values.each do |product_attribute_value|
        if product_attribute_value.product
          associated_products << product_attribute_value.product
        end
      end

      associated_products
    end

    def set_configurable_product_images(configurable_product)
      configurable_product.assets.destroy_all
      default_product = configurable_product.simple_products.first

      default_product.assets.each do |asset|
        asset_copy = asset.dup
        asset_copy.product = configurable_product
        asset_copy.asset_types = asset.asset_types
        asset_copy.sync_needed = true
        asset_copy.save
      end
    end

  end
end