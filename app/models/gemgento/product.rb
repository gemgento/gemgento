module Gemgento
  class Product < ActiveRecord::Base

    # TODO: handle 'store view' the Gemgento way
    # TODO: need a way to update product type via Gemgento

    belongs_to :product_attribute_set
    has_many :product_attribute_values
    has_and_belongs_to_many :categories, -> { uniq } , join_table: 'gemgento_categories_products'
    has_many :assets
    has_many :simple_products, foreign_key: 'parent_id', class_name: 'Product'
    belongs_to :configurable_product, foreign_key: 'parent_id', class_name: 'Product'
    has_and_belongs_to_many :configurable_attributes, -> { uniq } , join_table: 'gemgento_configurable_attributes', class_name: 'ProductAttribute'
    after_save :sync_local_to_magento

    def self.index
      if Product.find(:all).size == 0
        fetch_all
      end
      Product.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:catalog_product_list)
      response[:store_view][:item].each_with_index do |product, i|
        attribute_set = Gemgento::ProductAttributeSet.find_by(magento_id: product[:set])
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
      # if there is only one category, the returned value is not interpreted array
      unless magento_categories.is_a? Array
        magento_categories = [magento_categories]
      end

      # loop through each return category and add it to the product if needed
      magento_categories.each do |magento_category|
        category = Gemgento::Category.find_by(magento_id: magento_category)
        self.categories << category unless self.categories.include?(category) # don't duplicate the categories
      end
    end

    def set_attribute_values_from_magento(magento_attribute_values)
      magento_attribute_values.each do |attribute_value|
        self.set_attribute_value(attribute_value[:key], attribute_value[:value])
      end
    end

    def set_attribute_value(code, value)
      product_attribute = Gemgento::ProductAttribute.find_by(code: code)
      product_attribute_value = Gemgento::ProductAttributeValue.find_or_initialize_by(product_id: self.id, product_attribute_id: product_attribute.id)
      product_attribute_value.product = self
      product_attribute_value.product_attribute = product_attribute
      product_attribute_value.value = value
      product_attribute_value.save

      self.product_attribute_values << product_attribute_value unless self.product_attribute_values.include?(product_attribute_value)
    end

    def attribute_value(code)
      product_attribute = Gemgento::ProductAttribute.find_by(code: code)
      product_attribute_value = Gemgento::ProductAttributeValue.find_by(product_id: self.id, product_attribute_id: product_attribute.id)

      if product_attribute_value.nil?
        return nil
      end

      if product_attribute.product_attribute_options.empty?
        return product_attribute_value.value
      else
        return Gemgento::ProductAttributeOption.find_by(value: product_attribute_value.value).label
      end
    end

    def self.check_magento(identifier, identifier_type, attribute_set)
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

      product_info_response = Gemgento::Magento.create_call(:catalog_product_info, message)

      if product_info_response.nil?
        Gemgento::Product.new
      else
        sync_magento_to_local(product_info_response[:info])
      end
    end

    def self.associate_simple_products_to_configurable_products
      Gemgento::Product.where(magento_type: 'configurable').each do |configurable_product|
        configurable_product.simple_products = MagentoDB.associated_simple_products(configurable_product)
      end
    end

    private

    def self.sync_magento_to_local(subject)
      product = self.find_or_initialize_by(magento_id: subject[:product_id])
      product.magento_id = subject[:product_id]
      product.magento_type = subject[:type]
      product.sku = subject[:sku]
      product.sync_needed = false
      product.product_attribute_set = Gemgento::ProductAttributeSet.find_by(magento_id: subject[:set])
      product.save

      product.set_attribute_value('name', subject[:name])
      product.set_attribute_value('description', subject[:description])
      product.set_attribute_value('short_description', subject[:short_description])
      product.set_attribute_value('weight', subject[:weight])
      product.set_attribute_value('status', subject[:status])
      product.set_attribute_value('url_key', subject[:url_key])
      product.set_attribute_value('url_path', subject[:url_path])
      product.set_attribute_value('visibility', subject[:visibility])
      product.set_attribute_value('has_options', subject[:has_options])
      product.set_attribute_value('gift_message_available', subject[:gift_message_available])
      product.set_attribute_value('price', subject[:price])
      product.set_attribute_value('special_price', subject[:special_price])
      product.set_attribute_value('special_from_date', subject[:special_from_date])
      product.set_attribute_value('special_to_date', subject[:special_to_date])
      product.set_attribute_value('tax_class_id', subject[:tax_class_id])
      product.set_attribute_value('meta_title', subject[:meta_title])
      product.set_attribute_value('meta_keyword', subject[:meta_keyword])
      product.set_attribute_value('meta_description', subject[:meta_description])
      product.set_attribute_value('custom_design', subject[:custom_design])
      product.set_attribute_value('custom_layout_update', subject[:custom_layout_update])
      product.set_attribute_value('options_container', subject[:options_container])
      product.set_attribute_value('enable_googlecheckout', subject[:enable_googlecheckout])

      product.set_categories(subject[:categories][:item]) if subject[:categories][:item]
      product.set_attribute_values_from_magento(subject[:additional_attributes][:item]) if (subject[:additional_attributes] and subject[:additional_attributes][:item])

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
          set: self.product_attribute_set.magento_id,
          sku: self.sku,
          productData: compose_product_data,
          storeView: self.store_view
      }
      create_response = Gemgento::Magento.create_call(:catalog_product_create, message)
      self.magento_id = create_response[:result]
    end

    # Update existing Magento Product
    def update_magento
      message = { product: self.magento_id, product_identifier_type: 'id', product_data: compose_product_data}
      create_response = Gemgento::Magento.create_call(:catalog_product_update, message)
    end

    def compose_product_data
      product_data = {
          'name' => self.attribute_value('name'),
          'description' => self.attribute_value('description'),
          'short_description' => self.attribute_value('short_description'),
          'weight' => self.attribute_value('weight'),
          'status' => self.attribute_value('status'),
          'categories' => { 'item' => compose_categories },
          'url_key' => self.attribute_value('url_key'),
          'price' => self.attribute_value('price'),
          'additional_attributes' => { 'single_data' => { 'item' => compose_attribute_values }}
      }

      unless self.simple_products.empty?
        product_data.merge!({ 'associated_skus' => { 'item' => compose_associated_skus }, 'price_changes' => compose_price_changes })
      end

      product_data
    end

    def compose_associated_skus
      associated_skus = []

      self.simple_products.each do |simple_product|
        associated_skus << simple_product.sku
      end

      associated_skus
    end

    def compose_price_changes
      price_changes = []

      self.configurable_attributes.each do |configurable_attribute|
        options = []

        configurable_attribute.product_attribute_options.each do |attribute_option|
          options << { key: attribute_option.label, value: ''}
        end

        price_changes << { key: configurable_attribute.code, value: options }
      end

      price_changes
    end

    def product_data_attributes
      %w[name, description, short_description, weight, status, categories, url_key]
    end

    def compose_attribute_values
      attributes = []

      self.product_attribute_values.each do |product_attribute_value|
        unless product_attribute_value.value.nil?
          attributes << {
              'key' => product_attribute_value.product_attribute.code,
              'value' => product_attribute_value.value
          }
        end
      end

      attributes
    end

    def compose_categories
      categories = []

      self.categories.each do |category|
        categories << "#{category.magento_id}"
      end

      categories
    end
  end
end