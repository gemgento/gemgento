module Gemgento
  class Product < ActiveRecord::Base

    # TODO: need a way to update product type via Gemgento

    belongs_to :product_attribute_set
    has_many :product_attribute_values
    has_and_belongs_to_many :categories, -> { uniq } , join_table: 'gemgento_categories_products'
    has_many :assets
    has_many :simple_products, foreign_key: 'parent_id', class_name: 'Product'
    belongs_to :configurable_product, foreign_key: 'parent_id', class_name: 'Product'
    has_and_belongs_to_many :configurable_attributes, -> { uniq } , join_table: 'gemgento_configurable_attributes', class_name: 'ProductAttribute'
    after_save :sync_local_to_magento
    belongs_to :store
    has_one :inventory
    scope :configurable, where(magento_type: 'configurable')

    def self.index
      if Product.find(:all).size == 0
        API::SOAP::Catalog::Product.fetch_all
      end
      Product.find(:all)
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
      API::SOAP::Catalog::Product.check_magento(identifier, identifier_type, attribute_set)
    end

    private

    # Push local product changes to magento
    def sync_local_to_magento
      if self.sync_needed
        if !self.magento_id
          API::SOAP::Catalog::Product.create(self)
        else
          API::SOAP::Catalog::Product.update(self)
        end

        self.sync_needed = false
        self.save
      end
    end

  end
end