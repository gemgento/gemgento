module Gemgento

  # @author Gemgento LLC
  class ProductImport < Import

    NON_ATTRIBUTE_HEADERS = %w(sku status image visibility magento_type category)

    attr_accessor :simple_products

    validates_with ProductImportValidator, on: :create

    def default_options
      {
          image_labels: [],
          image_file_extensions: [],
          image_types: [],
          image_path: nil,
          product_attribute_set_id: nil,
          store_id: nil,
          root_category_id: nil,
          simple_product_visibility: 1,
          configurable_product_visibility: 1,
          set_default_inventory_values: false,
          include_images: false,
          configurable_attribute_ids: []
      }
    end

    def image_labels_raw
      image_labels.join("\n")
    end

    def image_labels_raw=(values)
      options[:image_labels] = values.gsub("\r", '').split("\n")
    end

    def image_file_extensions_raw
      image_file_extensions.join(', ')
    end

    def image_file_extensions_raw=(values)
      options[:image_file_extensions] = values.gsub(' ', '').split(',')
    end

    def image_types_raw
      image_types.join("\n")
    end

    def image_types_raw=(values)
      options[:image_types] = []
      options[:image_types] = values.gsub("\r", '').split("\n").map { |t| t.split(',').collect(&:strip) }
    end

    def include_images?
      options[:include_images].to_bool
    end

    def set_default_inventory_values?
      options[:set_default_inventory_values].to_bool
    end

    # @return [Gemgento::ProductAttributeSet]
    def product_attribute_set
      if options[:product_attribute_set_id].nil?
        nil
      else
        @product_attribute_set ||= Gemgento::ProductAttributeSet.find(options[:product_attribute_set_id])
      end
    end

    def store
      if options[:store_id].nil?
        nil
      else
        @store ||= Gemgento::Store.find(options[:store_id])
      end
    end

    def root_category
      if options[:root_category_id].nil?
        nil
      else
        @root_category ||= Gemgento::Category.find(options[:root_category_id])
      end
    end

    def configurable_attributes
      @configurable_attributes ||= Gemgento::ProductAttribute.where(is_configurable: true, id: options[:configurable_attribute_ids])
    end

    ### IMPORT PROCESSING ###

    def process_row
      self.simple_products ||= []

      if value('magento_type').casecmp('simple') == 0
        process_simple_product
      else
        process_configurable_product
      end
    end

    def process_simple_product
      simple_product = create_simple_product

      if simple_product.errors.any?
        self.process_errors << "Row ##{current_row}: #{simple_product.errors.full_messages.join(', ')}"
      else
        self.simple_products << simple_product
      end
    end

    def process_configurable_product
      configurable_product = create_configurable_product

      if configurable_product.errors.any?
        self.process_errors << "Row ##{current_row}: #{configurable_product.errors.full_messages.join(', ')}"
      end

      self.simple_products = []
    end

    # Create/Update a simple product.
    #
    # @return [Gemgento::Product]
    def create_simple_product
      sku = value('sku')

      product = Gemgento::Product.not_deleted.find_or_initialize_by(sku: sku)
      product.magento_id = existing_magento_id(sku)

      product.magento_type = 'simple'
      product.product_attribute_set = self.product_attribute_set
      product.stores << self.store unless product.stores.include?(self.store)
      product.status = value('status', :boolean)

      unless product.magento_id
        product.sync_needed = false
        product.save
      end

      product = set_attribute_values(product)
      set_categories(product)

      product.sync_needed = true

      if product.save
        create_images(product) if self.include_images?
        set_default_config_inventories(product) if self.set_default_inventory_values?
      end

      return product
    end

    # Set product attribute values supplied by spreadsheet.
    #
    # @param product [Gemgento::Product]
    # @return [Gemgento::Product]
    def set_attribute_values(product)
      self.header_row.each do |attribute_code|
        next if NON_ATTRIBUTE_HEADERS.include?(attribute_code)

        product_attribute = product_attribute_set.product_attributes.find_by!(code: attribute_code)
        value = value(attribute_code)
        value = value.gsub('.0', '') if value.end_with? '.0'

        if product_attribute.frontend_input == 'select'
          label = value
          attribute_option = product_attribute.product_attribute_options.find_by(label: label, store: self.store)

          if attribute_option.nil?
            attribute_option = create_attribute_option(product_attribute, label)
          end

          value = attribute_option.nil? ? nil : attribute_option.value
        end

        if value.nil?
          self.process_errors << "Row #{current_row}: Unknown attribute value '#{value(attribute_code)}' for code '#{attribute_code}'"
        else
          product.set_attribute_value(product_attribute.code, value, self.store)
        end
      end

      product = set_default_attribute_values(product)

      return product
    end

    # Create a new ProductAttributeOption.
    #
    # @param product_attribute [Gemgento::ProductAttribute]
    # @param option_label [String]
    # @return [Gemgento::ProductAttributeOption]
    def create_attribute_option(product_attribute, option_label)
      attribute_option = Gemgento::ProductAttributeOption.new
      attribute_option.product_attribute = product_attribute
      attribute_option.label = option_label
      attribute_option.store = self.store
      attribute_option.sync_local_to_magento

      return Gemgento::ProductAttributeOption.find_by(product_attribute: product_attribute, label: option_label, store: self.store)
    end

    # Set default attribute values based on options and missing values.
    #
    # @param product [Gemgento::Product]
    # @return [Gemgento::Product]
    def set_default_attribute_values(product)
      product.status = 1 if product.status.nil?
      product.visibility = self.simple_product_visibility.to_i

      if product.url_key.nil?
        url_key = product.name.to_s.strip.gsub(' ', '-').gsub(/[^\w\s]/, '').downcase
        product.set_attribute_value('url_key', url_key)
      end

      return product
    end

    # Associate Product with Categories.
    #
    # @param product [Gemgento::Product]
    # @return [void]
    def set_categories(product)
      categories = value('category').split('&')

      categories.each do |category_string|
        category_string.strip!
        subcategories = category_string.split('>')
        parent_id = self.root_category.id

        subcategories.each do |category_url_key|
          category_url_key.strip!
          category = Gemgento::Category.find_by(url_key: category_url_key, parent_id: parent_id)

          unless category.nil?
            pc = Gemgento::ProductCategory.find_or_create_by!(category: category, product: product, store: self.store)
            parent_id = category.id
            pc.sync_needed = true
            pc.save
          else
            self.process_errors << "Row ##{@index}: Unknown category url key '#{category_url_key}' - skipped"
          end
        end
      end
    end

    # Find and create all images for a Product.
    #
    # @param product [Gemgento::Product]
    # @return [void]
    def create_images(product)
      self.image_labels.each_with_index do |label, position|

        self.image_file_extensions.each do |extension|
          file_name = self.image_path + value('image') + '_' + label + extension
          next unless File.exist?(file_name)

          types = []

          unless self.image_types[position].nil?
            types = product_attribute_set.asset_types.where(code: self.image_types[position].split(',').map(&:strip))
          end

          image = Asset.new
          image.product = product
          image.store = self.store
          image.position = position
          image.label = label
          image.set_file(File.open(file_name))

          types.each do |type|
            image.asset_types << type
          end

          # save without sync to format with paperclip
          image.sync_needed = false
          image.save

          # save with sync to push to magento
          image.sync_needed = true
          image.save
        end
      end
    end

    # Create/Update a configurable product.
    #
    # @return [Gemgento::Product]
    def create_configurable_product
      sku = value('sku')

      # set the default configurable product attributes
      configurable_product = Gemgento::Product.not_deleted.find_or_initialize_by(sku: sku)
      configurable_product.magento_id = existing_magento_id(sku)

      configurable_product.magento_type = 'configurable'
      configurable_product.product_attribute_set = product_attribute_set
      configurable_product.status = value('status', :boolean)
      configurable_product.stores << store unless configurable_product.stores.include?(store)
      configurable_product.sync_needed = false
      configurable_product.save

      # add the configurable attributes
      configurable_attributes.each do |configurable_attribute|
        configurable_product.configurable_attributes << configurable_attribute unless configurable_product.configurable_attributes.include? configurable_attribute
      end

      # associate all simple products with the new configurable product
      self.simple_products.each do |simple_product|
        configurable_product.simple_products << simple_product unless configurable_product.simple_products.include?(simple_product)
      end

      # set the additional configurable product details
      set_attribute_values(configurable_product)
      set_categories(configurable_product)

      configurable_product.visibility = self.configurable_product_visibility.to_i
      configurable_product.sync_needed = true

      if configurable_product.save
        # add the images
        create_images(configurable_product) if include_images?
        set_default_config_inventories(configurable_product) if self.set_default_inventory_values?
      end

      return configurable_product
    end

    # @param product [Gemgento::Product]
    # @return [void]
    def set_default_config_inventories(product)
      inventory = product.inventories.find_or_initialize_by(store: self.store)
      inventory.use_config_manage_stock = true
      inventory.use_config_backorders = true
      inventory.use_config_min_qty = true
      inventory.sync_needed = true
      inventory.save
    rescue ActiveRecord::RecordNotUnique
      # when Magento pushes inventory data back, it will create missing inventory rows
      set_default_config_inventories(product)
    end

    # Look for existing magento_id based on sku
    #
    # @param sku [String]
    # @return [Integer, nil]
    def existing_magento_id(sku)
      magento_id = nil

      if magento_product = Magento::ProductAdapter.find_by(sku: sku)
        magento_id = magento_product[:product_id].to_i
        magento_id = nil unless magento_id > 0
      end

      return magento_id
    end

  end
end