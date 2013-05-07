module Gemgento
  class Product < ActiveRecord::Base

    # TODO: handle 'store view' the Gemgento way
    # TODO: need a way to update product type via Gemgento

    belongs_to :product_attribute_set
    has_many :product_attribute_values
    has_and_belongs_to_many :categories, :join_table => 'gemgento_categories_products', :uniq => true
    has_many :assets

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

        additional_attributes = []
        attribute_set.product_attributes.each do |attribute|
          additional_attributes << attribute.code
        end

        message = {
            product: product[:product_id],
            productIdentifierType: 'id',
            attributes: {
                'additional_attributes' => { 'arr:string' => additional_attributes }
            }
        }

        sync_magento_to_local(Gemgento::Magento.create_call(:catalog_product_info, message)[:info])
      end
    end

    def set_attribute_value(attribute, value)
      product_attribute_value = Gemgento::ProductAttributeValue.find_or_initialize_by_product_id_and_product_attribute_id(self.id, attribute.id)
      product_attribute_value.product_id = self.id
      product_attribute_value.product_attribute_id = attribute.id
      product_attribute_value.value = value
      product_attribute_value.save

      self.product_attribute_values << product_attribute_value unless self.product_attribute_values.include?(product_attribute_value)
    end

    private

    def self.sync_magento_to_local(subject)
      category = Category.find_by_magento_id(subject[:categories][:item])

      product = self.find_or_initialize_by_magento_id(subject[:product_id])
      product.magento_id = subject[:product_id]
      product.magento_type = subject[:type]
      product.name = subject[:name]
      product.url_key = subject[:url_key]
      product.price = subject[:price]
      product.sku = subject[:sku]
      product.sync_needed = false
      product.categories << category unless product.categories.include?(category) # don't duplicate the categories
      product.product_attribute_set = Gemgento::ProductAttributeSet.find_by_magento_id(subject[:set])
      product.save

      # set attribute values
      subject[:additional_attributes][:item].each do |attribute_value|
        product_attribute = Gemgento::ProductAttribute.find_by_code(attribute_value[:key])
        product.set_attribute_value(product_attribute, attribute_value[:value])
      end

      # set media assets
      Gemgento::Asset.fetch_all(product)
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
      product_data = {
          name: self.name,
          'url_key' => self.url_key,
          'price' => self.price,
          'additional_attributes' => {
            quality: self.quality,
            pattern: self.design,
            color: self.color,
            size: self.size,
            'style_code' => self.style_code
          }
      }
      message = { type: self.magento_type, set: self.set, sku: self.sku, productData: product_data, storeView: self.store_view  }
      create_response = Gemgento::Magento.create_call(:catalog_product_create, message)
      self.magento_id = create_response[:attribute_id]
    end

    # Update existing Magento Product
    def update_magento
      product_data = {
          name: self.name,
          'url_key' => self.url_key,
          'price' => self.price,
          'additional_attributes' => {
              quality: self.quality,
              pattern: self.design,
              color: self.color,
              size: self.size,
              'style_code' => self.style_code
          }
      }
      message = { product: self.magento_id, productIdentifierType: 'id', productData: product_data}
      create_response = Gemgento::Magento.create_call(:catalog_category_update, message)
    end
  end
end