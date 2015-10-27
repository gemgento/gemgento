module Gemgento

  # @author Gemgento LLC
  class Product < ActiveRecord::Base

    belongs_to :product_attribute_set

    has_many :assets, dependent: :destroy
    has_many :bundle_items, class_name: 'Gemgento::Bundle::Item', dependent: :destroy
    has_many :bundle_options, class_name: 'Gemgento::Bundle::Option', dependent: :destroy
    has_many :categories, -> { uniq }, through: :product_categories, class_name: 'Gemgento::Category'
    has_many :inventories, class_name: 'Gemgento::Inventory'
    has_many :line_items, class_name: 'Gemgento::LineItem'
    has_many :price_tiers, class_name: 'Gemgento::PriceTier'
    has_many :product_attribute_values, class_name: 'Gemgento::ProductAttributeValue', dependent: :destroy
    has_many :product_attributes, through: :product_attribute_values, class_name: 'Gemgento::ProductAttribute'
    has_many :product_attribute_options, through: :product_attribute_values, class_name: 'Gemgento::ProductAttributeOption'
    has_many :product_categories, class_name: '::Gemgento::ProductCategory', dependent: :destroy
    has_many :relations, as: :relatable, class_name: 'Relation', dependent: :destroy
    has_many :shipment_items
    has_many :wishlist_items
    has_many :users, through: :wishlist_items

    has_one :shopify_adapter, class_name: 'Adapter::ShopifyAdapter', as: :gemgento_model

    has_and_belongs_to_many :stores, -> { distinct }, join_table: 'gemgento_stores_products', class_name: 'Store'
    has_and_belongs_to_many :tags, class_name: 'Tag', join_table: 'gemgento_products_tags'
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

    before_save :create_magento_product, if: -> { sync_needed? && magento_id.nil? }
    before_save :update_magento_product, if: -> { sync_needed? && !magento_id.nil? }
    after_save :touch_categories, :touch_configurables

    before_destroy :delete_associations

    validates :sku, uniqueness: { scope: :deleted_at }

    attr_accessor :configurable_attribute_ordering

    # Set an attribute value.
    #
    # @param code [String] attribute code
    # @param value [String, Boolean, Integer, Float, BigDecimal]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def set_attribute_value(code, value, store = nil)
      store = Store.current if store.nil?

      product_attribute = ProductAttribute.find_by(code: code)

      if product_attribute.nil?
        return false
      else
        # enforce a single attribute value per attribute per store per product
        product_attribute_values = ProductAttributeValue.where(product_id: self.id, product_attribute_id: product_attribute.id, store: store)

        if product_attribute_values.size > 1
          ProductAttributeValue.where(product_id: self.id, product_attribute_id: product_attribute.id, store: store).where('id != ?', product_attribute_values.first.id).destroy_all
        end

        # set the attribute value
        product_attribute_value = ProductAttributeValue.where(product_id: self.id, product_attribute_id: product_attribute.id, store: store).first_or_initialize
        product_attribute_value.product = self
        product_attribute_value.product_attribute = product_attribute
        product_attribute_value.value = value
        product_attribute_value.store = store
        product_attribute_value.save

        self.product_attribute_values << product_attribute_value unless self.product_attribute_values.include?(product_attribute_value)

        return true
      end
    end

    # Get an attribute value.
    #
    # @param code [String] attribute code
    # @param store [Gemgento::Store]
    # @return [String, Boolean, nil]
    def attribute_value(code, store = nil)
      store = Store.current if store.nil?
      product_attribute_value = self.product_attribute_values.select { |value| !value.product_attribute.nil? && value.product_attribute.code == code.to_s && value.store_id == store.id }.first

      ## if the attribute is not currently associated with the product, check if it exists
      if product_attribute_value.nil?
        product_attribute = ProductAttribute.find_by(code: code)

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

    # Attempts to return attribute_value before error.
    def method_missing(method, *args)
      begin
        return self.attribute_value(method)
      rescue
        super
      end
    end

    # Determine if product has a specific inventory level.
    #
    # @param quantity [Integer, BigDecimal, Float]
    # @param store [Gemgento::Store]
    # @return [Boolean]
    def in_stock?(quantity = 1, store = nil)
      store = Store.current if store.nil?

      if self.magento_type == 'configurable'
        inventories = Inventory.where(product_id: self.simple_products.active.select(:id), store: store)

        if inventories.empty? # no inventories means inventory is not tracked
          return true
        else
          inventories.each do |inventory|
            return true if inventory.in_stock?(quantity)
          end

          return false
        end

      else
        if inventory = self.inventories.find_by(store: store)
          return inventory.in_stock?(quantity)
        else
          return true
        end
      end
    end

    # Mark a product deleted.
    #
    # @return [Void]
    def mark_deleted
      self.deleted_at = Time.now
      self.shopify_adapter.destroy if self.shopify_adapter
    end

    # Mark a product deleted and save.
    #
    # @return [Void]
    def mark_deleted!
      mark_deleted
      self.save
    end

    # Filter products based on attribute values.
    #
    #   filter example:
    #     {attribute: Gemgento::ProductAttribute.find_by(code: 'size'), value: 'large'})
    #     or
    #     {attribute: Gemgento::ProductAttribute.find_by(code: 'size'), value: %w[large small]})
    #     or
    #     {attribute: [Gemgento::ProductAttribute.find_by(code: 'size'), Gemgento::ProductAttribute.find_by(code: 'dimension')], value: 'large'})
    #     or
    #     {attribute: [Gemgento::ProductAttribute.find_by(code: 'size'), Gemgento::ProductAttribute.find_by(code: 'dimension')], value: %w[large small]})
    #     or
    #     [{attribute: Gemgento::ProductAttribute.find_by(code: 'size'), value: 'large'}), {attribute: Gemgento::ProductAttribute.find_by(code: 'color'), value: 'red'})]
    #
    #   Filters can also take an optional operand, the default operand is '=' or 'IN' for an array
    #
    # @param filters [Hash, Array(Hash)]
    # @param store [Gemgento::Store]
    # @return [ActiveRecord::Result]
    def self.filter(filters, store = nil)
      store = Store.current if store.nil?

      filters = [filters] unless filters.is_a? Array
      products = self

      filters.each_with_index do |filter, index|
        filter[:attribute] = [filter[:attribute]] unless filter[:attribute].is_a? Array
        operand = filter[:value].is_a?(Array) ? 'IN' : ( filter.has_key?(:operand) ? filter[:operand] : '=' )
        value_placeholder = filter[:value].is_a?(Array) ? '(?)' : '?'

        unless filter[:attribute][0].frontend_input == 'select'
          products = products.joins(ActiveRecord::Base.escape_sql(
                                        "INNER JOIN gemgento_product_attribute_values AS value#{index} ON value#{index}.product_id = gemgento_products.id AND value#{index}.value #{operand} #{value_placeholder} AND value#{index}.store_id = ?
                    INNER JOIN gemgento_product_attributes AS attribute#{index} ON attribute#{index}.id = value#{index}.product_attribute_id AND attribute#{index}.id IN (?)",
                                        filter[:value],
                                        store.id,
                                        filter[:attribute].map { |a| a.id }
                                    )).distinct.readonly(false)
        else
          products = products.joins(ActiveRecord::Base.escape_sql(
                                        "INNER JOIN gemgento_product_attribute_values AS value#{index} ON value#{index}.product_id = gemgento_products.id
                    INNER JOIN gemgento_product_attributes AS attribute#{index} ON attribute#{index}.id = value#{index}.product_attribute_id
                      AND attribute#{index}.id IN (?)
                    INNER JOIN gemgento_product_attribute_options AS option#{index} ON option#{index}.product_attribute_id = attribute#{index}.id
                      AND value#{index}.value = option#{index}.value
                      AND option#{index}.label #{operand} #{value_placeholder}",
                                        filter[:attribute].map { |a| a.id },
                                        filter[:value]
                                    )).distinct.readonly(false) # does not compare against values
        end
      end

      return products
    end

    # Order ActiveRecord result by attribute values.
    #
    # @param attribute [Gemgento::ProductAttribute]
    # @param direction ['ASC', 'DESC']
    # @param is_numeric [Boolean]
    # @param store [Gemgento::Store]
    # @return [ActiveRecord::Result]
    def self.order_by_attribute(attribute, direction = 'ASC', is_numeric = false, store = nil)
      store = Store.current if store.nil?
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

    # Get the product price.
    #
    # @param user_group [Gemgento::UserGroup]
    # @param store [Store]
    # @param quantity [Float]
    # @return Float
    def price(user_group = nil, store = nil, quantity = 1.0)
      Gemgento::Price.new(self, user_group, store, quantity).calculate
    end

    # Determine if product is on sale.
    #
    # @param user_group [Gemgento::UserGroup]
    # @param store [Store]
    # @param quantity [Float]
    # @return Boolean
    def on_sale?(user_group = nil, store = nil, quantity = 1.0)
      return self.attribute_value('price', store).to_f != self.price(user_group, store, quantity)
    end

    # Get the original, non sale, price for a product.
    #
    # @param [Store, nil] store
    # @return [Float]
    def original_price(store = nil)
      return self.attribute_value('price', store).to_f
    end

    # Return the ordering of configurable attribute values.
    #
    # @param [Store, nil] store
    # @param [Boolean] active_only
    # @param [Hash(Hash(Array(Integer)))]
    def configurable_attribute_order(store = nil, active_only = true)
      self.configurable_attribute_ordering ||= self.get_configurable_attribute_ordering(store, active_only)
    end

    # Calculate the ordering of configurable attribute values
    #
    # @param [Store, nil] store
    # @param [Boolean] active_only
    # @return [Hash(Hash(Array(Integer)))]
    def get_configurable_attribute_ordering(store, active_only)
      store = Store.current if store.nil?
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
        simple_product = Product.active.find_by(magento_id: magento_id)
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
        configurable_product = Product.active.find_by(magento_id: magento_id)
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

      Store.all.each do |store|
        UserGroup.all.each do |user_group|
          if Price.new(self, user_group, store)
            date =  self.attribute_value('special_to_date', store)
          else
            date =  PriceRule.first_to_expire(self, user_group, store)
          end

          next if date.nil?
          self.cache_expires_at = date if self.cache_expires_at.nil? || date < self.cache_expires_at
        end
      end

      self.sync_needed = false
      self.save
    end

    def to_param
      "#{self.id}-#{self.url_key}"
    end

    # Determine the current category of a product based on the active navigation categories related to the product.
    # A preferred category id can be specified, if this category is not found in the products navigation categories,
    # then the lowest level navigation category is returned.
    #
    # @param category_id [Integer] id of a preferred category to return
    # @param store [Gemgento::Store]
    # @return [Gemgento::Category]
    def current_category(category_id = nil, store = nil)
      @current_category ||= begin
        self.categories(store || Gemgento::Store.current).active.navigation.find(category_id)
      rescue ActiveRecord::RecordNotFound
        self.categories(store || Gemgento::Store.current).active.navigation.bottom_level.first!
      end
    end

    # Check if the product is configurable.
    #
    # @return [Boolean]
    def configurable?
      magento_type == 'configurable'
    end

    # Check if the product is simple.
    #
    # @return [Boolean]
    def simple?
      magento_type == 'simple'
    end

    # Categories related to the product.
    #
    # @param store [Gemgento::Store]
    # @return []
    def categories(store = nil)
      return super if store.nil?
      Gemgento::Category.where(id: self.product_categories.where(store: store).pluck(:category_id))
    end

    private

    # Create an attribute option in Magento.
    #
    # @param product_attribute [ProductAttribute]
    # @param option_label [String]
    # @param store [Store]
    # @return [ProductAttributeOption]
    def create_attribute_option(product_attribute, option_label, store)
      attribute_option = ProductAttributeOption.new
      attribute_option.product_attribute = product_attribute
      attribute_option.label = option_label
      attribute_option.store = store
      attribute_option.sync_needed = false
      attribute_option.save

      attribute_option.sync_local_to_magento
      attribute_option.destroy

      return ProductAttributeOption.find_by(product_attribute: product_attribute, label: option_label, store: store)
    end

    # Create an associated magento Product.
    #
    # @return [Boolean]
    def create_magento_product
      response = API::SOAP::Catalog::Product.create(self, self.stores.first)

      if response.success?
        self.magento_id = response.body[:result]
        self.sync_needed = false

        stores.each_with_index do |store, index|
          next if index == 0
          response = API::SOAP::Catalog::Product.update(self, store)

          # If there was a problem updating on of the stores, then make sure the product will be synced on next save.
          # The product needs to be saved regardless, since a Magento product was created and the id must be set.  So,
          # this will not return false.
          self.sync_needed = true unless response.success?
        end

        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Update associated Magento Product.
    #
    # @return [Boolean]
    def update_magento_product
      self.stores.each do |store|
        response = API::SOAP::Catalog::Product.update(self, store)

        unless response.success?
          errors.add(:base, response.body[:faultstring])
          return false
        end
      end

      self.sync_needed = false
      return true
    end

    # Delete associations.
    #
    # @return [Void]
    def delete_associations
      self.configurable_attributes.destroy_all
    end

    # Touch all associated categories.
    #
    # @return [Void]
    def touch_categories
      TouchCategory.perform_async(self.categories.pluck(:id)) if self.changed?
    end

    # Touch associated configurable products.
    #
    # @return [Void]
    def touch_configurables
      self.configurable_products.update_all(updated_at: Time.now) if self.changed?
      TouchProduct.perform_async(self.configurable_products.pluck(:id)) if self.changed?
    end

    def to_ary
      nil
    end

    alias :to_a :to_ary

  end
end
