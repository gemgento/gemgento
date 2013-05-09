module Gemgento
  class ProductImport < ActiveRecord::Base
=begin
-Loop through each row
  -Load category
    -Create it if it doesn't exist
  -Load product
    -Initialize new one if it doesn't exist
  -Update all attributes with row values
  -Update image asset with row values
  -Save product
  -Increment hash count on style_code by 1

-Loop through hash
  -If value greater than 1
    -Create a configurable product if it doesn't already exist
    -Add the simple products to the configurable product
=end

    def initialize(file)
      @worksheet = Spreadsheet.open(file).worksheet(0)
      @headers = get_headers
      @messages = []
      @product_count = 0
      @attribute_of_association = 'style_code'
      @associated_simple_products = {}

      1.upto @worksheet.last_row_index do |index|
        next if @worksheet.row(index)[0].nil? && @worksheet.row(index)[1].nil?
          @row = @worksheet.row(index)
          product = create_simple_product
          add_image(product)
          track_associated_simple_products(product)
          @product_count += 1
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
      # TODO: create the product from the given row and headers
      set_categories(product)
    end

    def set_categories(product)
      # TODO: find or create the categories and associate them with the product
    end

    def add_image(product)
      # TODO: If the image is not already associated with the product, add it
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
          attribute_value.to_s!
          simple_products = associated_products(attribute_value)
          #TODO: Create the configurable product and add the simple products
        end
      end
    end

    def associated_products(attribute_value)
      product_attribute = Gemgento::ProductAttribute.find_by_code(@attribute_of_association)
      associated_products = []

      Gemgento::ProductAttributeValue.find_by_product_attribute_and_value(product_attribute, attribute_value).each do |product_attribute_value|
        associated_products << product_attribute_value.product
      end
    end

  end
end