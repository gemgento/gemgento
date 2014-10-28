module Gemgento
  class Product < ActiveRecord::Base

    belongs_to :product_attribute_set
    belongs_to :swatch

    has_many :assets, dependent: :destroy
    has_many :categories, -> { distinct }, through: :product_categories
    has_many :inventories
    has_many :order_items
    has_many :product_attribute_values, dependent: :destroy
    has_many :product_attributes, through: :product_attribute_values
    has_many :product_attribute_options, through: :product_attribute_values
    has_many :product_categories, -> { distinct }, dependent: :destroy
    has_many :relations, as: :relatable, class_name: 'Gemgento::Relation', dependent: :destroy
    has_many :shipment_items

    has_one :shopify_adapter, class_name: 'Gemgento::Adapter::ShopifyAdapter', as: :gemgento_model

    has_and_belongs_to_many :stores, -> { distinct }, join_table: 'gemgento_stores_products', class_name: 'Gemgento::Store'
    has_and_belongs_to_many :tags, class_name: 'Gemgento::Tag', join_table: 'gemgento_products_tags'
    has_and_belongs_to_many :configurable_attributes, -> { distinct }, join_table: 'gemgento_configurable_attributes', class_name: 'Gemgento::ProductAttribute'
    has_and_belongs_to_many :configurable_products, -> { distinct },
                            join_table: 'gemgento_configurable_simple_relations',
                            foreign_key: 'simple_product_id',
                            association_foreign_key: 'configurable_product_id',
                            class_name: 'Gemgento::Product'
    has_and_belongs_to_many :simple_products, -> { distinct },
                            join_table: 'gemgento_configurable_simple_relations',
                            foreign_key: 'configurable_product_id',
                            association_foreign_key: 'simple_product_id',
                            class_name: 'Gemgento::Product'

    scope :eager, -> { includes([{product_attribute_values: :product_attribute}, {assets: [:asset_file, :asset_types]}, :inventories]) }
    scope :configurable, -> { where(magento_type: 'configurable') }
    scope :simple, -> { where(magento_type: 'simple') }
    scope :enabled, -> { where(status: true) }
    scope :disabled, -> { where(status: false) }
    scope :catalog_visible, -> { where(visibility: [2, 4]) }
    scope :search_visible, -> { where(visibility: [3, 4]) }
    scope :visible, -> { where(visibility: [2, 3, 4]) }
    scope :not_deleted, -> { where(deleted_at: nil) }
    scope :active, -> { where(deleted_at: nil, status: true) }

    after_find :manage_cache_expires_at

    after_save :sync_local_to_magento, :touch_categories, :touch_configurables

    before_destroy :delete_associations

    validates :sku, uniqueness: { scope: :deleted_at }

    attr_accessor :configurable_attribute_ordering

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
        # enforce a single attribute value per attribute per store per product
        product_attribute_values = Gemgento::ProductAttributeValue.where(product_id: self.id, product_attribute_id: product_attribute.id, store: store)

        if product_attribute_values.size > 1
          Gemgento::ProductAttributeValue.where(product_id: self.id, product_attribute_id: product_attribute.id, store: store).where('id != ?', product_attribute_values.first.id).destroy_all
        end

        # if there are option values, get the actual value instead of label
        if product_attribute.frontend_input == 'select'
          return true if value.nil?
          attribute_option = Gemgento::ProductAttributeOption.find_by(product_attribute_id: product_attribute.id, label: value, store: store)

          if attribute_option.nil?
            attribute_option = Gemgento::ProductAttributeOption.find_by(product_attribute_id: product_attribute.id, value: value, store: store)

            if attribute_option.nil?
              attribute_option = create_attribute_option(product_attribute, value, store)
              return false if attribute_option.nil?
            end
          end

          value = attribute_option.value
        end

        # set the attribute value
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
      product_attribute_value = self.product_attribute_values.select { |value| !value.product_attribute.nil? && value.product_attribute.code == code.to_s && value.store_id == store.id }.first

      ## if the attribute is not currently associated with the product, check if it exists
      if product_attribute_value.nil?
        product_attribute = Gemgento::ProductAttribute.find_by(code: code)

        if product_attribute.nil? # throw an error if the code is not recognized
          raise "Unknown product attribute code - #{code}"
        end
      else
        product_attribute = product_attribute_value.product_attribute
      end

      value = product_attribute_value.nil? ? product_attribute.default_value : product_attribute_value.value
      return nil if value.nil?

      if product_attribute.frontend_input == 'boolean' || product_attribute.code == 'is_recurring'
        if value == 'Yes' || value == '1' || value == '1.0'
          value = true
        else
          value = false
        end
      elsif product_attribute.frontend_input == 'select'
        option = product_attribute.product_attribute_options.find_by(value: value, store: store)
        value = option.nil? ? nil : option.label
      end

      return value
    end

    def self.check_magento(identifier, identifier_type, attribute_set, store = nil)
      store = Gemgento::Store.current if store.nil?
      API::SOAP::Catalog::Product.check_magento(identifier, identifier_type, attribute_set, store)
    end

    # Attempts to return relations before method missing response
    def method_missing(method, *args)
      begin
        return self.attribute_value(method)
      rescue
        super
      end
    end

    def in_stock?(quantity = 1, store = nil)
      store = Gemgento::Store.current if store.nil?

      if self.magento_type == 'simple'
        inventory = self.inventories.find_by(store: store)
        if inventory.nil? # no inventory means inventory is not tracked
          return true;
        else
          return inventory.in_stock?(quantity)
        end
      else # check configurable product inventory
        # load inventories with out completely loading the associated simple products
        inventories = Gemgento::Inventory.where(product_id: self.simple_products.select(:id), store: store)

        if inventories.empty? # no inventories means inventory is not tracked
          return true
        else
          inventories.each do |inventory|
            return true if inventory.in_stock?(quantity)
          end

          return false
        end
      end
    end

    def mark_deleted
      self.deleted_at = Time.now
      self.shopify_adapter.destroy if self.shopify_adapter
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

    def self.filter(filters, store = nil)
      store = Gemgento::Store.current if store.nil?

      filters = [filters] unless filters.is_a? Array
      products = self

      filters.each_with_index do |filter, index|
        filter[:attribute] = [filter[:attribute]] unless filter[:attribute].is_a? Array

        unless filter[:attribute][0].frontend_input == 'select'
          products = products.joins(ActiveRecord::Base.escape_sql(
                                        "INNER JOIN gemgento_product_attribute_values AS value#{index} ON value#{index}.product_id = gemgento_products.id AND value#{index}.value IN (?) AND value#{index}.store_id = ?
                    INNER JOIN gemgento_product_attributes AS attribute#{index} ON attribute#{index}.id = value#{index}.product_attribute_id AND attribute#{index}.id IN (?)",
                                        filter[:value],
                                        store.id,
                                        filter[:attribute].map { |a| a.id }
                                    )).readonly(false)
        else
          products = products.joins(ActiveRecord::Base.escape_sql(
                                        "INNER JOIN gemgento_product_attribute_values AS value#{index} ON value#{index}.product_id = gemgento_products.id
                    INNER JOIN gemgento_product_attributes AS attribute#{index} ON attribute#{index}.id = value#{index}.product_attribute_id
                      AND attribute#{index}.id IN (?)
                    INNER JOIN gemgento_product_attribute_options AS option#{index} ON option#{index}.product_attribute_id = attribute#{index}.id
                      AND value#{index}.value = option#{index}.value
                      AND option#{index}.label IN (?)",
                                        filter[:attribute].map { |a| a.id },
                                        filter[:value]
                                    )).readonly(false) # does not compare against values
        end
      end

      return products
    end

    def self.order_by_attribute(attribute, direction = 'ASC', is_numeric = false, store = nil)
      store = Gemgento::Store.current if store.nil?
      raise 'Direction must be equivalent to ASC or DESC' if direction != 'ASC' and direction != 'DESC'

      products = self

      unless attribute.frontend_input == 'select'
        products = products.joins(
            ActiveRecord::Base.escape_sql(
                'INNER JOIN gemgento_product_attribute_values ON gemgento_product_attribute_values.product_id = gemgento_products.id AND gemgento_product_attribute_values.product_attribute_id = ? AND gemgento_product_attribute_values.store_id = ? ' +
                    'INNER JOIN gemgento_product_attributes ON gemgento_product_attributes.id = gemgento_product_attribute_values.product_attribute_id ',
                attribute.id,
                store.id
            ))

        if is_numeric
          products = products.reorder("CAST(gemgento_product_attribute_values.value AS SIGNED) #{direction}")
        else
          products = products.reorder("gemgento_product_attribute_values.value #{direction}")
        end
      else
        products = products.joins(
            ActiveRecord::Base.escape_sql(
                'INNER JOIN gemgento_product_attribute_values ON gemgento_product_attribute_values.product_id = gemgento_products.id AND gemgento_product_attribute_values.product_attribute_id = ? ' +
                    'INNER JOIN gemgento_product_attributes ON gemgento_product_attributes.id = gemgento_product_attribute_values.product_attribute_id ' +
                    'INNER JOIN gemgento_product_attribute_options ON gemgento_product_attribute_options.product_attribute_id = gemgento_product_attributes.id AND gemgento_product_attribute_options.value = gemgento_product_attribute_values.value ' +
                    'AND gemgento_product_attribute_options.store_id = ?',
                attribute.id,
                store.id
            ))

        if is_numeric
          products = products.reorder("CAST(gemgento_product_attribute_options.order AS SIGNED) #{direction}")
        else
          products = products.reorder("gemgento_product_attribute_options.order #{direction}")
        end
      end

      products = products.readonly(false)

      return products
    end

    def swatches
      swatches = []

      self.simple_products.each do |p|
        swatches << p.swatch unless p.swatch.nil? || swatches.include?(p.swatch)
      end

      return swatches
    end

    # Get the product price.
    #
    # @param user [Gemgento::User]
    # @param store [Gemgento::Store]
    # @return Float
    def price(user = nil, store = nil)
      if self.has_special?(store)
        return self.attribute_value('special_price', store).to_f
      else
        return Gemgento::PriceRule.calculate_price(self, user, store)
      end
    end

    # Determine if a product has a valid special price set.
    #
    # @param [Gemgento::Store] store
    # @return [Boolean]
    def has_special?(store = nil)
      special_price = self.attribute_value('special_price', store)
      special_from_date = self.attribute_value('special_from_date', store)
      special_to_date = self.attribute_value('special_to_date', store)

      if special_price.nil? # no special price
        return false
      elsif special_from_date.nil? && special_to_date.nil?
        return true
      elsif special_from_date.nil? && !special_to_date.nil?
        return Date.parse(special_to_date) >= Date.today
      elsif special_to_date.nil? && !special_from_date.nil?
        return Date.parse(special_from_date) <= Date.today
      else
        return Date.parse(special_from_date) <= Date.today && Date.parse(special_to_date) >= Date.today
      end
    end

    # Determine if product is on sale.
    #
    # @param user [Gemgento::User]
    # @param store [Gemgento::Store]
    # @return Boolean
    def on_sale?(user = nil, store = nil)
      return self.attribute_value('price', store).to_f != self.price(user, store)
    end

    # Get the original, non sale, price for a product.
    #
    # @param [Gemgento::Store, nil] store
    # @return [Float]
    def original_price(store = nil)
      return self.attribute_value('price', store).to_f
    end

    # Return the ordering of configurable attribute values.
    #
    # @param [Gemgento::Store, nil] store
    # @param [Boolean] active_only
    # @param [Hash(Hash(Array(Integer)))]
    def configurable_attribute_order(store = nil, active_only = true)
      self.configurable_attribute_ordering ||= self.get_configurable_attribute_ordering(store, active_only)
    end

    # Calculate the ordering of configurable attribute values
    #
    # @param [Gemgento::Store, nil] store
    # @param [Boolean] active_only
    # @return [Hash(Hash(Array(Integer)))]
    def get_configurable_attribute_ordering(store, active_only)
      store = Gemgento::Store.current if store.nil?
      order = {}

      if self.magento_type != 'configurable' && !self.configurable_products.empty?
        configurable_product = self.configurable_products.first
      else
        configurable_product = self
      end

      if active_only
        simple_products = configurable_product.simple_products.active.eager
      else
        simple_products = self.simple_products.eager
      end

      configurable_attributes = self.product_attribute_set.product_attributes.
          where(is_configurable: true, frontend_input: 'select', scope: 'global')

      configurable_attributes.each do |attribute|
        order[attribute.code] = {}

        simple_products = simple_products.sort_by do |simple_product|
          if o = simple_product.product_attribute_options.find_by(product_attribute: attribute, store: store)
            o.order
          else
            0
          end
        end

        simple_products.each do |simple_product|
          value = simple_product.attribute_value(attribute.code, store)
          order[attribute.code][value] = [] if order[attribute.code][value].nil?
          order[attribute.code][value] << simple_product.id unless order[attribute.code][value].include? simple_product.id
        end
      end

      return order
    end

    # Determine if the product is catalog visible.
    #
    # @return [Boolean]
    def is_catalog_visible?
      return [2, 4].include?(self.visibility)
    end

    # Set the associated simple products, using an array of Magento product IDs.
    #
    # @param magento_ids [Array(Integer)] Magento IDs of the associated simple products
    # @return [void]
    def set_simple_products_by_magento_ids(magento_ids)
      simple_product_ids = []

      magento_ids.each do |magento_id|
        simple_product = Gemgento::Product.find_by(magento_id: magento_id)
        next if simple_product.nil?

        self.simple_products << simple_product unless self.simple_products.include? simple_product
        simple_product_ids << simple_product.id
      end

      self.simple_products.delete(self.simple_products.where('simple_product_id NOT IN (?)', simple_product_ids))
    end

    # Set the associated configurable products, using an array of Magento product IDs.
    #
    # @param magento_ids [Array(Integer)] Magento IDs of the associated configurable products
    # @return [void]
    def set_configurable_products_by_magento_ids(magento_ids)
      configurable_product_ids = []

      magento_ids.each do |magento_id|
        configurable_product = Gemgento::Product.find_by(magento_id: magento_id)
        next if configurable_product.nil?

        self.configurable_products << configurable_product unless self.configurable_products.include? configurable_product
        configurable_product_ids << configurable_product.id
      end

      self.configurable_products.delete(self.configurable_products.where('configurable_product_id NOT IN (?)', configurable_product_ids))
    end

    # If the product has a cache_expires_at date set, make sure it hasn't expired.  If it has, set it again.
    #
    # @return [DateTime, nil]
    def manage_cache_expires_at
      self.set_cache_expires_at if self.cache_expires_at && self.cache_expires_at < Time.now
    end

    # Calculate the datetime that the product cache should expire.
    #
    # @return [Void]
    def set_cache_expires_at
      self.cache_expires_at = nil

      Gemgento::Store.all.each do |store|
        Gemgento::UserGroup.all.each do |user_group|
          if self.has_special?(store)
            date =  self.attribute_value('special_to_date', store)
          else
            date =  Gemgento::PriceRule.first_to_expire(self, user_group, store)
          end

          next if date.nil?
          self.cache_expires_at = date if self.cache_expires_at.nil? || date < self.cache_expires_at
        end
      end

      self.sync_needed = false
      self.save
    end

    private

    # Create an attribute option in Magento.
    #
    # @param product_attribute [Gemgento::ProductAttribute]
    # @param option_label [String]
    # @param store [Gemgento::Store]
    # @return [Gemgento::ProductAttributeOption]
    def create_attribute_option(product_attribute, option_label, store)
      attribute_option = ProductAttributeOption.new
      attribute_option.product_attribute = product_attribute
      attribute_option.label = option_label
      attribute_option.store = store
      attribute_option.sync_needed = false
      attribute_option.save

      attribute_option.sync_local_to_magento
      attribute_option.destroy

      return Gemgento::ProductAttributeOption.find_by(product_attribute: product_attribute, label: option_label, store: store)
    end

    # Push local product changes to magento
    def sync_local_to_magento
      if self.sync_needed && self.deleted_at.nil?
        if !self.magento_id
          API::SOAP::Catalog::Product.create(self, self.stores.first)

          self.stores.each_with_index do |store, index|
            next if index == 0
            API::SOAP::Catalog::Product.update(self, store)
          end
        else
          self.stores.each do |store|
            API::SOAP::Catalog::Product.update(self, store)
          end
        end

        self.sync_needed = false
        self.save
      end
    end

    def delete_associations
      self.configurable_attributes.destroy_all
    end

    def touch_categories
      Gemgento::TouchCategory.perform_async(self.categories.pluck(:id)) if self.changed?
    end

    def touch_configurables
      self.configurable_products.update_all(updated_at: Time.now) if self.changed?
      Gemgento::TouchProduct.perform_async(self.configurable_products.pluck(:id)) if self.changed?
    end

    def to_ary
      nil
    end

    alias :to_a :to_ary

  end
end
