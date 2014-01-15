module Gemgento
  class Product < ActiveRecord::Base

    belongs_to :product_attribute_set
    belongs_to :swatch

    has_one :inventory

    has_many :product_attribute_values, dependent: :destroy
    has_many :product_attributes, through: :product_attribute_values
    has_many :assets, dependent: :destroy
    has_many :relations, -> { distinct }, as: :relatable, :class_name => 'Relation', dependent: :destroy
    has_many :product_categories, -> { distinct }, dependent: :destroy
    has_many :categories, -> { distinct }, through: :product_categories

    has_and_belongs_to_many :stores, -> { distinct }, join_table: 'gemgento_stores_products', class_name: 'Store'
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

    default_scope -> { includes([{product_attribute_values: :product_attribute}, {assets: [:asset_file, :asset_types]}, :inventory, :swatch]) }

    scope :configurable, -> { where(magento_type: 'configurable') }
    scope :simple, -> { where(magento_type: 'simple') }
    scope :enabled, -> { where(status: true) }
    scope :disabled, -> { where(status: false) }
    scope :catalog_visible, -> { where(visibility: [2, 4]) }
    scope :search_visible, -> { where(visibility: [3, 4]) }
    scope :not_deleted, -> { where(deleted_at: nil) }
    scope :active, -> { where(deleted_at: nil, status: true) }

    after_save :sync_local_to_magento, :touch_categories, :touch_configurables

    before_destroy :delete_associations

    validates_uniqueness_of :sku, :scope => [:deleted_at]

    def self.index
      if Product.all.size == 0
        API::SOAP::Catalog::Product.fetch_all
      end
      Product.all
    end

    def set_attribute_value(code, value, store = nil)
      store = Gemgento::Store.current if store.nil?

      product_attribute = Gemgento::ProductAttribute.find_by(code: code)

      if product_attribute.nil?
        return false
      else
        product_attribute_value = Gemgento::ProductAttributeValue.where(product_id: self.id, product_attribute_id: product_attribute.id, store: store).first_or_initialize
        product_attribute_value.product = self
        product_attribute_value.product_attribute = product_attribute
        product_attribute_value.value = value
        product_attribute_value.store = store
        product_attribute_value.save

        self.product_attribute_values << product_attribute_value unless self.product_attribute_values.include?(product_attribute_value)

        return true
      end

    end

    def attribute_value(code, store = nil)
      store = Gemgento::Store.current if store.nil?
      product_attribute_value = self.product_attribute_values.select { |value| value.product_attribute.code == code.to_s && value.store_id == store.id }.first

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
        option = product_attribute.product_attribute_options.find_by(store: store, value: value)
        value = option.nil? ? nil : option.label
      end

      return value
    end

    def self.check_magento(identifier, identifier_type, attribute_set)
      API::SOAP::Catalog::Product.check_magento(identifier, identifier_type, attribute_set, Gemgento::Store.current)
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
          product_attribute_values = product_attribute.product_attribute_options.where(label: value, store: Gemgento::Store.current).product_attribute_values
        end

        products = products.joins(:product_attribute_values).where('gemgento_product_attribute_values.value' => product_attribute_values)
      end

      return products
    end

    def in_stock?(quantity = 1)
      if self.magento_type == 'simple'
        if self.inventory.nil? # no inventory means inventory is not tracked
          return true;
        else
          return self.inventory.in_stock?
        end
      else # check configurable product inventory
        # load inventories with out completely loading the associated simple products
        inventories = Gemgento::Inventory.where(product_id: self.simple_products.select(:id))

        if inventories.empty? # no inventories means inventory is not tracked
          return true
        else
          inventories.each do |inventory|
            return true if inventory.in_stock?
          end

          return false
        end
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

    def self.filter(filters)
      filters = [filters] unless filters.is_a? Array
      products = self

      filters.each_with_index do |filter, index|
        filter[:attribute] = [filter[:attribute]] unless filter[:attribute].is_a? Array

        unless filter[:attribute][0].frontend_input == 'select'
          products = products.joins(ActiveRecord::Base.escape_sql(
                                        "INNER JOIN gemgento_product_attribute_values AS value#{index} ON value#{index}.product_id = gemgento_products.id AND value#{index}.value IN (?)
                    INNER JOIN gemgento_product_attributes AS attribute#{index} ON attribute#{index}.id = value#{index}.product_attribute_id AND attribute#{index}.id IN (?)",
                                        filter[:value],
                                        filter[:attribute].map { |a| a.id }
                                    )).readonly(false)
        else
          products = products.joins(ActiveRecord::Base.escape_sql(
                                        "INNER JOIN gemgento_product_attribute_values AS value#{index} ON value#{index}.product_id = gemgento_products.id
                    INNER JOIN gemgento_product_attributes AS attribute#{index} ON attribute#{index}.id = value#{index}.product_attribute_id AND attribute#{index}.id IN (?)
                    INNER JOIN gemgento_product_attribute_options AS option#{index} ON option#{index}.product_attribute_id = attribute#{index}.id AND option#{index}.store_id = ? AND option#{index}.label IN (?)",
                                        filter[:attribute].map { |a| a.id },
                                        Gemgento::Store.current.id,
                                        filter[:value]
                                    )).readonly(false)
        end
      end

      return products
    end

    def self.order_by_attribute(attribute, direction = 'ASC')
      raise 'Direction must be equivalent to ASC or DESC' if direction != 'ASC' and direction != 'DESC'

      products = self

      unless attribute.frontend_input = 'select'
        products = products.joins(
            ActiveRecord::Base.escape_sql(
                'INNER JOIN gemgento_product_attribute_values ON gemgento_product_attribute_values.product_id = gemgento_products.id AND gemgento_product_attribute_values.product_attribute_id = ? ' +
                    'INNER JOIN gemgento_product_attributes ON gemgento_product_attributes.id = gemgento_product_attribute_values.product_attribute_id ',
                attribute.id
            )).
            order("gemgento_product_attribute_values.value #{direction}").
            readonly(false)
      else
        products = products.joins(
            ActiveRecord::Base.escape_sql(
                'INNER JOIN gemgento_product_attribute_values ON gemgento_product_attribute_values.product_id = gemgento_products.id AND gemgento_product_attribute_values.product_attribute_id = ? ' +
                    'INNER JOIN gemgento_product_attributes ON gemgento_product_attributes.id = gemgento_product_attribute_values.product_attribute_id ' +
                    'INNER JOIN gemgento_product_attribute_options ON gemgento_product_attribute_options.product_attribute_id = gemgento_product_attributes.id AND gemgento_product_attribute_options.value = gemgento_product_attribute_values.value' +
                    'AND gemgento_product_attribute_options.store_id = ?',
                attribute.id,
                Gemgento::Store.current.id
            )).
            order("gemgento_product_attribute_options.order #{direction}").
            readonly(false)
      end

      return products
    end

    def swatches
      swatches = []

      self.simple_products.each do |p|
        swatches << p.swatch unless p.swatch.nil? || swatches.include?(p.swatch)
      end

      return swatches
    end

    def price
      if self.has_special?
        return self.special_price
      else
        return self.attribute_value 'price'
      end
    end

    def has_special?
      if self.special_price.nil? # no special price
        return false
      elsif self.special_from_date.nil? && self.special_to_date.nil? # no start or end date
        return true
      elsif self.special_from_date.nil? && Date.parse(special_to_date) >= Date.today # no start date and end date is in the future
        return true
      elsif self.special_to_date.nil? && Date.parse(special_from_date) <= Date.today # no end date and start date is in the past
        return true
      elsif Date.parse(self.special_from_date) <= Date.today && Date.parse(self.special_to_date) >= Date.today # start date is in the past and end date is in the future
        return true
      else
        return false
      end
    end

    def original_price
      return self.attribute_value('price')
    end

    def as_json(options = nil)
      store = Gemgento::Store.current
      result = super

      self.product_attribute_values.select{ |av| av.store_id == store.id }.each do |attribute_value|
        attribute = attribute_value.product_attribute
        result[attribute.code] = self.attribute_value(attribute.code, store)
      end

      # product assets
      result['assets'] = []
      self.images.each do |image|
        styles = { 'original' => image.image.url(:original) }

        image.image.styles.keys.to_a.each do |style|
          styles[style] = image.image.url(style.to_sym)
        end

        result['assets'] << {
            label: image.label,
            styles: styles
        }
      end

      # include simple products
      if self.simple_products.loaded?
        result['simple_products'] = []

        self.simple_products.each do |simple_product|
          result['simple_products'] << simple_product
        end
      end

      # inventory flag
      result['is_in_stock'] = self.in_stock?

      return result
    end

    def configurable_options(attribute_code)
      raise 'Product not configurable' if self.magento_type != 'configurable'
      attribute = Gemgento::ProductAttribute.find_by(code: attribute_code)
      options = []

      self.simple_products.active.order_by_attribute(attribute).each do |p|
        options << p.attribute_value(attribute_code)
      end

      return options
    end

    def images
      self.assets.select{ |a| a.store_id == Gemgento::Store.current.id }
    end

    private

    # Push local product changes to magento
    def sync_local_to_magento
      if self.sync_needed
        if !self.magento_id
          API::SOAP::Catalog::Product.create(self, Gemgento::Store.current)
        else
          API::SOAP::Catalog::Product.update(self, Gemgento::Store.current)
        end

        self.sync_needed = false
        self.save
      end
    end

    def delete_associations
      self.configurable_attributes.destroy_all
    end

    def touch_categories
      self.categories.update_all(updated_at: Time.now) if self.changed?
    end

    def touch_configurables
      self.configurable_products.update_all(updated_at: Time.now) if self.changed?
    end

    def to_ary
      nil
    end

    alias :to_a :to_ary

  end
end
