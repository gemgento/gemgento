module Gemgento
  class Product < ActiveRecord::Base

    belongs_to :store
    belongs_to :product_attribute_set
    belongs_to :swatch

    has_one :inventory

    has_many :product_attribute_values, dependent: :destroy
    has_many :assets, dependent: :destroy
    has_many :relations, -> { distinct }, as: :relatable, :class_name => 'Relation'

    has_and_belongs_to_many :categories, -> { distinct }, join_table: 'gemgento_categories_products'
    has_and_belongs_to_many :configurable_attributes, -> { distinct }, join_table: 'gemgento_configurable_attributes', class_name: 'ProductAttribute'
    has_and_belongs_to_many :configurable_products, -> { distinct },
                            join_table: 'gemgento_configurable_simple_relations',
                            foreign_key: 'simple_product_id',
                            association_foreign_key: 'configurable_product_id',
                            class_name: 'Product'
    has_and_belongs_to_many :simple_products, -> { distinct },
                            join_table: 'gemgento_configurable_simple_relations',
                            foreign_key: 'configurable_product_id',
                            association_foreign_key: 'simple_product_id',
                            class_name: 'Product'

    default_scope -> { includes([{product_attribute_values: :product_attribute}, :assets, :inventory, :swatch]) }

    scope :configurable, -> { where(magento_type: 'configurable') }
    scope :simple, -> { where(magento_type: 'simple') }
    scope :enabled, -> { where(status: true) }
    scope :disabled, -> { where(status: false) }
    scope :catalog_visible, -> { where(visibility: [2, 4]) }
    scope :search_visible, -> { where(visibility: [3, 4]) }
    scope :not_deleted, -> { where(deleted_at: nil) }
    scope :active, -> { where(deleted_at: nil, status: true) }

    after_save :sync_local_to_magento

    before_destroy :delete_associations

    validates_uniqueness_of :sku, :scope => [:deleted_at]

    def self.index
      if Product.all.size == 0
        API::SOAP::Catalog::Product.fetch_all
      end
      Product.all
    end

    def set_attribute_value(code, value)
      product_attribute = Gemgento::ProductAttribute.where(code: code).first
      product_attribute_value = Gemgento::ProductAttributeValue.where(product_id: self.id, product_attribute_id: product_attribute.id).first_or_initialize
      product_attribute_value.product = self
      product_attribute_value.product_attribute = product_attribute
      product_attribute_value.value = value
      product_attribute_value.save

      self.product_attribute_values << product_attribute_value unless self.product_attribute_values.include?(product_attribute_value)
    end

    def attribute_value(code)
      product_attribute_value = self.product_attribute_values.select { |value| value.product_attribute.code == code.to_s }.first

      ## if the attribute is not currently associated with the product, check if it exists
      if product_attribute_value.nil?
        product_attribute = Gemgento::ProductAttribute.find_by(code: code)

        if product_attribute.nil? # throw an error if the code is not recognized
          raise "Unknown product attribute code - #{code}"
        end
      else
        product_attribute = product_attribute_value.product_attribute
      end

      if product_attribute_value.nil?
        value = product_attribute.default_value

        if value.nil?
          return nil
        end
      else
        value = product_attribute_value.value
      end

      if product_attribute.frontend_input == 'boolean'
        if value == 'Yes' || value == '1' || value == '1.0'
          value = true
        else
          value = false
        end
      elsif product_attribute.frontend_input == 'select'
        option = product_attribute.product_attribute_options.find_by(value: value)
        value = option.nil? ? nil : option.label
      end

      return value
    end

    def self.check_magento(identifier, identifier_type, attribute_set)
      API::SOAP::Catalog::Product.check_magento(identifier, identifier_type, attribute_set)
    end

    # Attempts to return relations before method missing response
    def method_missing(method, *args)
      begin
        return self.attribute_value(method)
      rescue
        super
      end
    end

    def self.by_attributes(filters)
      products = Gemgento::Product.configurable

      filters.each do |code, value|
        product_attribute = ProductAttribute.find_by(code: code)
        next if product_attribute.nil?

        if product_attribute.product_attribute_options.empty?
          product_attribute_values = product_attribute.product_attribute_values.where(value: value)
        else
          product_attribute_values = product_attribute.product_attribute_options.where(label: value).product_attribute_values
        end

        products = products.joins(:product_attribute_values).where('gemgento_product_attribute_values.value' => product_attribute_values)
      end

      return products
    end

    def in_stock?
      if self.inventory.nil?
        return true;
      elsif self.inventory.is_in_stock
        return true;
      else
        return false
      end
    end

    def mark_deleted
      self.deleted_at = Time.now
    end

    def mark_deleted!
      mark_deleted
      self.save
    end

    def related(relation_name)
      relation_type = RelationType.find_by(name: relation_name)
      raise "Unknown relation type - #{relation_name}" if relation_type.nil?

      return self.relations.where(relation_type: relation_type).collect { |relation| relation.related_to }
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

    def delete_associations
      self.categories.clear
      self.configurable_attributes.clear
      self.relations.clear

      unless self.simple_products.nil?
        self.simple_products.each do |simple_product|
          simple_product.configurable_products.clear
          simple_product.save
        end
      end
    end

    def to_ary
      nil
    end

    alias :to_a :to_ary

  end
end