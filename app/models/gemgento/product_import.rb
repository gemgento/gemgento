module Gemgento
  class ProductImport < ActiveRecord::Base
=begin
Pre-requisites:
-Column headers match attribute codes
-There is only one attribute set, or the needed attribute set is the first one
-All needed attributes already belong to the attribute set

Assumptions
-'Collections' is the parent category of the 'parent_category' column
-'Collections' already exists
-Only 'child_category' is assigned to product
-Two assets are created from one image and additional assumptions are made
  1 - types(image, small_image)
    - suffix = '.jpg'
  2 - types(thumbnail)
    - suffix = '_thumbnail.jpg'
=end

    def initialize(file)
      @worksheet = Spreadsheet.open(file).worksheet(0)
      @headers = get_headers
      @messages = []
      @attribute_of_association = 'style_code'
      @associated_simple_products = {}
      @attribute_set = Gemgento::ProductAttributeSet.first # assuming there is only one product attribute set
      @root_category = Gemgento::Category.find_by_parent_id_and_name(1, 'Collections')

      1.upto @worksheet.last_row_index do |index|
        next if @worksheet.row(index)[0].nil? && @worksheet.row(index)[1].nil?
          @row = @worksheet.row(index)
          product = create_simple_product
          track_associated_simple_products(product)
      end

      create_configurable_products
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
      product = Gemgento::Product.find_by_sku(@row[@headers.index('sku')])

      if product.nil? # If product isn't known locally, check with Magento
        product = Gemgento::Product.check_magento(@row[@headers.index('sku')], 'sku', @attribute_set)
      end

      product.magento_type = 'simple'
      product.sku = @row[@headers.index('sku')]
      product.attribute_set = @attribute_set
      product.save

      set_attribute_values(product)
      set_categories(product)
      set_image(product)

      product
    end

    def set_attribute_values(product)
      @headers.each do |index, attribute_code|
        product_attribute = Gemgento::ProductAttribute.find_by_code(attribute_code) # try to load attribute associated with column header

        # apply the attribute value if the attribute exists and is part of the attribute set
        if !product_attribute.nil? && @attribute_set.product_attributes.include?(product_attribute)

          # attribute value may have to be associated with an attribute option id
          if product_attribute.product_attribute_options
            value = Gemgento::ProductAttributeOption.find_by_product_attribute_id_and_label(product_attribute.id, @row[@headers[index]]).value
          else
            value = @row[@headers[index]]
          end

          product.set_attribute_value(product_attribute.code, value)
        end
      end
    end

    def set_categories(product)
      parent_category = Gemgento::Category.find_by_parent_id_and_name(@root_category.magento_id, @row[@headers.index('parent_category')])

      if parent_category.nil?
        parent_category = create_category(@row[@headers.index('parent_category')], @root_category)
      end

      child_category = Gemgento::Category.find_by_parent_id_and_name(parent_category.magenot_id, @row[@headers.index('child_category')])

      if child_category.nil?
        child_category = create_category(@row[@headers.index('child_category')], parent_category)
      end

      product.categories << child_category unless product.categories.include?(child_category)
    end

    def create_category(name, parent_category)
      category = Gemgento::Category.new
      category.parent_id = parent_category.magento_id
      category.name = name
      category.save

      category
    end

    def set_image(product)
      product.assets.destroy_all

      image = create_asset('.jpg')
      image.asset_types << Gemgento::AssetType.find_by_code('image')
      image.asset_types << Gemgento::AssetType.find_by_code('small_image')
      product.assets << image

      thumbnail = create_asset('_thumbnail.jpg')
      thumbnail.asset_types << Gemgento::AssetType.find_by_code('thumbnail')
      product.assets << thumbnail
    end

    def create_asset(suffix)
      asset = Gemgento::Asset.new
      asset.url = @row[@headers.index('image')] + suffix
      asset.save
    end

    def track_associated_simple_products(product)
      if @associated_simple_products[:"#{product.get_attribute_value(@attribute_of_association)}"].nil?
        @associated_simple_products[:"#{product.get_attribute_value(@attribute_of_association)}"] = 1
      else
        @associated_simple_products[:"#{product.get_attribute_value(@attribute_of_association)}"] += 1
      end
    end

    def create_configurable_products
      @associated_simple_products.each do |attribute_value, product_count|
        if product_count > 1
          simple_products = fetch_associated_products(attribute_value.to_s!)
          #TODO: create a ConfigurableProduct

        end
      end
    end

    def fetch_associated_products(attribute_value)
      product_attribute = Gemgento::ProductAttribute.find_by_code(@attribute_of_association)
      associated_products = []

      Gemgento::ProductAttributeValue.find_by_product_attribute_and_value(product_attribute, attribute_value).each do |product_attribute_value|
        associated_products << product_attribute_value.product
      end
    end

  end
end