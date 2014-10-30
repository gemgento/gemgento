require 'spreadsheet'
require 'open-uri'

module Gemgento
  class ProductImport < ActiveRecord::Base
    include ActiveModel::Validations
    belongs_to :product_attribute_set
    belongs_to :root_category, foreign_key: 'root_category_id', class_name: 'Category'
    belongs_to :store

    has_and_belongs_to_many :configurable_attributes, -> { distinct }, join_table: 'gemgento_product_imports_configurable_attributes', class_name: 'ProductAttribute'

    has_attached_file :spreadsheet

    serialize :import_errors, Array
    serialize :image_labels, Array
    serialize :image_file_extensions, Array
    serialize :image_types, Array

    attr_accessor :image_labels_raw
    attr_accessor :image_file_extensions_raw
    attr_accessor :image_types_raw

    validates_with ProductImportValidator

    after_commit :process

    def process
      # create a fake sync record, so products are not synced during the import
      sync_buffer = Sync.new
      sync_buffer.subject = 'products'
      sync_buffer.is_complete = false
      sync_buffer.save

      if self.spreadsheet.url =~ URI::regexp
        @worksheet = Spreadsheet.open(open(self.spreadsheet.url)).worksheet(0)
      else
        @worksheet = Spreadsheet.open(self.spreadsheet.path).worksheet(0)
      end

      @headers = get_headers
      @index = 0
      associated_simple_products = []
      self.import_errors = []
      self.count_created = 0
      self.count_updated = 0

      1.upto @worksheet.last_row_index do |index|
        @index = index
        puts "Working on row #{@index}"
        @row = @worksheet.row(@index)

        if @row[@headers.index('magento_type').to_i].to_s.strip.casecmp('simple') == 0
          associated_simple_products << create_simple_product
        else
          create_configurable_product(associated_simple_products)
          associated_simple_products = []
        end
      end

      ProductImport.skip_callback(:commit, :after, :process)
      self.save validate: false

      sync_buffer.is_complete = true
      sync_buffer.created_at = Time.now
      sync_buffer.save
      ProductImport.set_callback(:commit, :after, :process)
    end

    def image_labels_raw
      self.image_labels.join("\n") unless self.image_labels.nil?
    end

    def image_labels_raw=(values)
      self.image_labels = []
      self.image_labels = values.gsub("\r", '').split("\n")
    end

    def image_file_extensions_raw
      self.image_file_extensions.join(', ') unless self.image_file_extensions.nil?
    end

    def image_file_extensions_raw=(values)
      self.image_file_extensions = []
      self.image_file_extensions = values.gsub(' ', '').split(',')
    end

    def image_types_raw
      self.image_types.join("\n") unless self.image_types.nil?
    end

    def image_types_raw=(values)
      self.image_types = []
      self.image_types = values.gsub("\r", '').split("\n")
    end

    def image_path=(path)
      path = "#{path}/" unless path[-1, 1].to_s == '/'
      self[:image_path] = path
    end

    private

    def get_headers
      accepted_headers = []

      @worksheet.row(0).each do |h|
        unless h.nil?
          accepted_headers << h.downcase.gsub(' ', '_').strip
        end
      end

      accepted_headers
    end

    def create_simple_product
      sku = @row[@headers.index('sku').to_i].to_s.strip

      product = Product.where(sku: sku).not_deleted.first_or_initialize

      if product.nil? # If product isn't known locally, check with Magento
        product = Product.check_magento(sku, 'sku', product_attribute_set)
      end

      if product.magento_id.nil?
        self.count_created += 1
      else
        self.count_updated += 1
      end

      product.magento_type = 'simple'
      product.sku = sku
      product.product_attribute_set = self.product_attribute_set
      product.stores << self.store unless product.stores.include?(self.store)
      product.status = @row[@headers.index('status').to_i].to_i

      unless product.magento_id
        product.sync_needed = false
        product.save
      end

      product = set_attribute_values(product)
      set_categories(product)

      product.sync_needed = true
      product.save

      create_images(product) if self.include_images

      product
    end

    def set_attribute_values(product)
      @headers.each do |attribute_code|
        product_attribute = ProductAttribute.find_by(code: attribute_code) # try to load attribute associated with column header

        # apply the attribute value if the attribute exists
        if !product_attribute.nil? && attribute_code != 'sku' && attribute_code != 'status' && attribute_code != 'image'

          if product_attribute.frontend_input == 'select'
            label = @row[@headers.index(attribute_code).to_i].to_s.strip.gsub('.0', '')
            label = label.gsub('.0', '') if label.end_with? '.0'
            attribute_option = ProductAttributeOption.find_by(product_attribute_id: product_attribute.id, label: label, store: self.store)

            if attribute_option.nil?
              attribute_option = create_attribute_option(product_attribute, label)
            end

            value = attribute_option.value
          else # attribute value may have to be associated with an attribute option id
            value = @row[@headers.index(attribute_code).to_i].to_s.strip
            value = value.gsub('.0', '') if value.end_with? '.0'
          end

          product.set_attribute_value(product_attribute.code, value, self.store)
        elsif product_attribute.nil? && attribute_code != 'sku' && attribute_code != 'magento_type' && attribute_code != 'category'
          self.import_errors << "ERROR - row #{@index} - Unknown attribute code, '#{attribute_code}'"
        end
      end

      product = set_default_attribute_values(product)

      return product
    end

    def create_attribute_option(product_attribute, option_label)
      attribute_option = ProductAttributeOption.new
      attribute_option.product_attribute = product_attribute
      attribute_option.label = option_label
      attribute_option.store = self.store
      attribute_option.sync_needed = false
      attribute_option.save

      attribute_option.sync_needed = true
      attribute_option.sync_local_to_magento
      attribute_option.destroy

      return ProductAttributeOption.where(product_attribute: product_attribute, label: option_label, store: self.store).first
    end

    def set_default_attribute_values(product)
      product.status = 1 if product.status.nil?
      product.visibility = self.simple_product_visibility.to_i

      if product.url_key.nil?
        url_key = product.name.to_s.strip.gsub(' ', '-').gsub(/[^\w\s]/, '').downcase
        product.set_attribute_value('url_key', url_key)
      end

      return product
    end

    def set_categories(product)
      categories = @row[@headers.index('category').to_i].to_s.strip.split('&')

      categories.each do |category_string|
        category_string.strip!
        subcategories = category_string.split('>')
        parent_id = self.root_category.id

        subcategories.each do |category_url_key|
          category_url_key.strip!
          category = Category.find_by(url_key: category_url_key, parent_id: parent_id)

          unless category.nil?
            product_category = ProductCategory.find_or_initialize_by(category: category, product: product, store: self.store)
            product_category.save
            parent_id = category.id
          else
            self.import_errors << "ERROR - row #{@index} - Unknown category url key '#{category_url_key}' - skipped"
          end
        end
      end
    end

    def create_images(product)
      product.assets.where(store: self.store).destroy_all

      images_found = false
      # find the correct image file name and path
      self.image_labels.each_with_index do |label, position|

        self.image_file_extensions.each do |extension|
          file_name = self.image_path + @row[@headers.index('image').to_i].to_s.strip + '_' + label + extension
          next unless File.exist?(file_name)

          types = []

          unless self.image_types[position].nil?
            types = AssetType.where('product_attribute_set_id = ? AND code IN (?)', self.product_attribute_set.id, self.image_types[position].split(',').map(&:strip))
          end

          unless types.is_a? Array
            types = [types]
          end

          create_image(product, file_name, types, position, label)
          images_found = true
        end
      end

      unless images_found
        self.import_errors << "WARNING: No images found for id:#{product.id}, sku: #{product.sku}"
      end
    end

    def create_image(product, file_name, types, position, label)
      image = Asset.new
      image.product = product
      image.store = self.store
      image.position = position
      image.label = label
      image.set_file(File.open(file_name))

      types.each do |type|
        image.asset_types << type
      end

      image.sync_needed = false
      image.save

      image.sync_needed = true
      image.save

      image
    end

    def create_configurable_product(simple_products)
      sku = @row[@headers.index('sku').to_i].to_s.strip

      # set the default configurable product attributes
      configurable_product = Product.where(sku: sku).not_deleted.first_or_initialize

      if configurable_product.magento_id.nil?
        self.count_created += 1
      else
        self.count_updated += 1
      end

      configurable_product.magento_type = 'configurable'
      configurable_product.sku = sku

      configurable_product.product_attribute_set = product_attribute_set
      configurable_product.status = @row[@headers.index('status').to_i].to_i
      configurable_product.stores << store unless configurable_product.stores.include?(store)
      configurable_product.sync_needed = false
      configurable_product.save

      # associate all simple products with the new configurable product
      simple_products.each do |simple_product|
        configurable_product.simple_products << simple_product unless configurable_product.simple_products.include?(simple_product)
      end

      # add the configurable attributes
      configurable_attributes.each do |configurable_attribute|
        configurable_product.configurable_attributes << configurable_attribute unless configurable_product.configurable_attributes.include? configurable_attribute
      end

      # set the additional configurable product details
      set_attribute_values(configurable_product)
      set_categories(configurable_product)

      configurable_product.visibility = self.configurable_product_visibility.to_i

      # push to magento
      configurable_product.sync_needed = true
      configurable_product.save

      # add the images
      create_configurable_images(configurable_product) if include_images

    end

    def create_configurable_images(configurable_product)
      configurable_product.assets.where(store: self.store).destroy_all
      default_product = configurable_product.simple_products.first

      default_product.assets.where(store: self.store).each do |asset|
        asset_copy = Asset.new
        asset_copy.product = configurable_product
        asset_copy.store = self.store
        asset_copy.set_file(File.open(asset.asset_file.file.path(:original)))
        asset_copy.label = asset.label
        asset_copy.position = asset.position
        asset_copy.asset_types = asset.asset_types

        asset_copy.sync_needed = false
        asset_copy.save

        asset_copy.sync_needed = true
        asset_copy.save
      end
    end

  end
end