module Gemgento
  class Product < ActiveRecord::Base

    # TODO: handle 'store view' the Gemgento way
    # TODO: need a way to update product type via Gemgento

    belongs_to :product_attribute_set
    has_many :product_attribute_values
    has_and_belongs_to_many :categories, :join_table => 'gemgento_categories_products', :uniq => true
    has_many :assets
    has_many :simple_products, foreign_key: 'parent_id', class_name: 'Product'
    belongs_to :configurable_product, foreign_key: 'parent_id', class_name: 'Product'
    after_save :sync_local_to_magento

    def initialize
      self.sync_needed = true
    end

    def self.index
      if Product.find(:all).size == 0
        fetch_all
      end
      Product.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:catalog_product_list)
      response[:store_view][:item].each_with_index do |product, i|
        attribute_set = Gemgento::ProductAttributeSet.find_by_magento_id(product[:set])
         fetch(product[:product_id], attribute_set)
      end
    end

    def self.fetch(magento_id, attribute_set)
      additional_attributes = []
      attribute_set.product_attributes.each do |attribute|
        additional_attributes << attribute.code
      end

      message = {
          product: magento_id,
          productIdentifierType: 'id',
          attributes: {
              'additional_attributes' => { 'arr:string' => additional_attributes }
          }
      }

      sync_magento_to_local(Gemgento::Magento.create_call(:catalog_product_info, message)[:info])
    end

    def set_categories(magento_categories)
      self.categories.delete

      # if there is only one category, the returned value is not interpreted array
      unless magento_categories.is_a? Array
        magento_categories = [magento_categories]
      end

      # loop through each return category and add it to the product if needed
      magento_categories.each do |magento_category|
        category = Category.find_by_magento_id(magento_categories)
        self.categories << category unless self.categories.include?(category) # don't duplicate the categories
      end
    end

    def set_attribute_values_from_magento(magento_attribute_values)
      # TODO: remove existing attribute values before adding new ones to account for removed attributes in Magento
      magento_attribute_values.each do |attribute_value|
        self.set_attribute_value(attribute_value[:key], attribute_value[:value])
      end
    end

    def set_attribute_value(code, value)
      product_attribute = Gemgento::ProductAttribute.find_by_code(code)
      product_attribute_value = Gemgento::ProductAttributeValue.find_or_initialize_by_product_id_and_product_attribute_id(self.id, product_attribute.id)
      product_attribute_value.product = self
      product_attribute_value.product_attribute = product_attribute
      product_attribute_value.value = value
      product_attribute_value.save

      self.product_attribute_values << product_attribute_value unless self.product_attribute_values.include?(product_attribute_value)
    end

    def attribute_value(code)
      product_attribute = Gemgento::ProductAttribute.find_by_code(code)
      product_attribute_value = Gemgento::ProductAttributeValue.find_by_product_id_and_product_attribute_id(self.id, product_attribute.id)

      if product_attribute.product_attribute_options
        attribute_value = product_attribute_option = Gemgento::ProductAttributeOption.find_by_value(product_attribute_value.value).label
      else
        attribute_value = product_attribute_value.value
      end

      attribute_value
    end

    def check_magento(identifier, identifier_type, attribute_set)
      additional_attributes = []
      attribute_set.product_attributes.each do |attribute|
        additional_attributes << attribute.code
      end

      message = {
          product: identifier,
          productIdentifierType: identifier_type,
          attributes: {
              'additional_attributes' => { 'arr:string' => additional_attributes }
          }
      }

      begin
        product_info_response = Gemgento::Magento.create_call(:catalog_product_info, message)
        product = sync_magento_to_local(product_info_response[:info])
      rescue
        product = Gemgento::Product.new
      end

      product
    end

    private

    def self.sync_magento_to_local(subject)
      product = self.find_or_initialize_by_magento_id(subject[:product_id])
      product.magento_id = subject[:product_id]
      product.magento_type = subject[:type]
      product.sku = subject[:sku]
      product.sync_needed = false
      product.product_attribute_set = Gemgento::ProductAttributeSet.find_by_magento_id(subject[:set])
      product.save

      product.set_categories(subject[:categories][:item])
      product.set_attribute_values_from_magento(subject[:additional_attributes][:item])

      # set media assets
      Gemgento::Asset.fetch_all(product)

      product
    end

    # Push local product changes to magento
    def sync_local_to_magento
      if self.sync_needed
        if !self.magento_id
          create_magento
        else
          update_magento
        end

        self.sync_needed = false
        self.save
      end
    end

    # Create a new Product in Magento and set out magento_id
    def create_magento
      message = {
          type: self.magento_type,
          set: self.set, sku: self.sku,
          productData: compose_product_data,
          storeView: self.store_view
      }
      create_response = Gemgento::Magento.create_call(:catalog_product_create, message)
      self.magento_id = create_response[:attribute_id]
    end

    # Update existing Magento Product
    def update_magento
      message = { product: self.magento_id, product_identifier_type: 'id', product_data: compose_product_data}
      create_response = Gemgento::Magento.create_call(:catalog_product_update, message)
    end

    def compose_product_data
      product_data = {
          'name' => self.get_attribute_value('name'),
          'description' => self.get_attribute_value('description'),
          'short_description' => self.get_attribute_value('short_description'),
          'weight' => self.get_attribute_value('weight'),
          'status' => self.get_attribute_value('status'),
          'categories' => compose_categories,
          'url_key' => self.get_attribute_value('url_key'),
          'price' => self.get_attribute_value('price'),
          'additional_attributes' => { 'single_data' => { items: compose_attribute_values }}
      }

      if self.type == 'configurable'
        product_data[:configurable_products_data] = compose_configurable_products
        product_data[:configurable_attributes_data] = compose_configurable_attributes
      end

      product_data
    end

    def compose_configurable_products
      #TODO: find the associated simple products and compose their configurable attributes for API push to Magento
    end

    def compose_configurable_attributes
      #TODO: determine the configurable attributes and compose the data for API push to Magento
    end

    def product_data_attributes
      %w[name, description, short_description, weight, status, categories, url_key]
    end

    def compose_attribute_values
      attributes = []

      unless product_attribute_value.value.nil?
        attributes << { key: product_attribute_value.product_attribute.code, value: product_attribute_value.value }
      end

      attributes
    end

    def compose_categories
      categories = []

      self.categories.each do |category|
        categories << "#{category.id}"
      end

      categories
    end
  end
end