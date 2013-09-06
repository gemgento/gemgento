require 'spreadsheet'

module Gemgento
  class ProductImport < ActiveRecord::Base
    belongs_to :product_attribute_set
    belongs_to :root_category, foreign_key: 'root_category_id', class_name: 'Category'
    belongs_to :store

    has_and_belongs_to_many :configurable_attributes, -> { distinct }, join_table: 'gemgento_product_imports_configurable_attributes', class_name: 'ProductAttribute'

    has_attached_file :spreadsheet

    serialize :import_errors, Array
    serialize :image_labels, Array

    attr_accessor :image_labels_raw

    after_commit :process

    def process
      # create a fake sync record, so products are not synced during the import
      sync_buffer = Gemgento::Sync.new
      sync_buffer.subject = 'products'
      sync_buffer.is_complete = false
      sync_buffer.save

      @worksheet = Spreadsheet.open(self.spreadsheet.path).worksheet(0)
      @headers = get_headers
      associated_simple_products = []
      self.import_errors = []
      self.count_created = 0
      self.count_updated = 0

      1.upto @worksheet.last_row_index do |index|
        puts "Working on row #{index}"
        @row = @worksheet.row(index)

        if @row[@headers.index('magento_type').to_i].to_s.strip.casecmp('simple') == 0
          associated_simple_products << create_simple_product
        else
          create_configurable_product(associated_simple_products)
          associated_simple_products = []
        end
      end

      ProductImport.skip_callback(:commit, :after, :process)
      self.save

      sync_buffer.is_complete = true
      sync_buffer.created_at = Time.now
      sync_buffer.save
    end

    def image_labels_raw
      self.image_labels.join("\n") unless self.image_labels.nil?
    end

    def image_labels_raw=(values)
      self.image_labels = []
      self.image_labels = values.gsub("\r", '').split("\n")
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

      product = Product.find_by(sku: sku)

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
      product.product_attribute_set = product_attribute_set
      product.store = store
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
        if !product_attribute.nil? && attribute_code != 'sku' && attribute_code != 'status'

          if product_attribute.product_attribute_options.empty?
            value = @row[@headers.index(attribute_code).to_i].to_s.strip
          else # attribute value may have to be associated with an attribute option id
            label = @row[@headers.index(attribute_code).to_i].to_s.strip
            attribute_option = Gemgento::ProductAttributeOption.find_by(product_attribute_id: product_attribute.id, label: label)

            if attribute_option.nil?
              attribute_option = create_attribute_option(product_attribute, label)
            end

            value = attribute_option.value
          end

          product.set_attribute_value(product_attribute.code, value)
        elsif product_attribute.nil? && attribute_code != 'sku' && attribute_code != 'magento_type' && attribute_code != 'category'
          self.import_errors << "ERROR - row #{@row.index} - Unknown attribute code, '#{attribute_code}'"
        end
      end

      product = set_default_attribute_values(product)

      return product
    end

    def create_attribute_option(product_attribute, option_label)
      attribute_option = ProductAttributeOption.new
      attribute_option.product_attribute = product_attribute
      attribute_option.label = option_label
      attribute_option.save

      attribute_option.sync_local_to_magento
      attribute_option.reload

      attribute_option
    end

    def set_default_attribute_values(product)
      product.status = 1 if product.status.nil?
      product.visibility = self.simple_product_visibility.to_i

      if product.attribute_value('url_key').blank?
        url_key = product.attribute_value('name').to_s.strip.gsub(' ', '-').gsub(/[^\w\s]/, '').downcase
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
            product.categories << category unless product.categories.include?(category)
            parent_id = category.id
          else
            self.import_errors << "ERROR - row #{@row.index} - Unknown category url key '#{category_url_key}' - skipped"
          end
        end
      end
    end

    def create_images(product)
      product.assets.destroy_all

      images_found = false
      # find the correct image file name and path
      self.image_labels.each_with_index do |label, position|
        file_name = self.image_path + @row[@headers.index('image').to_i].to_s.strip + '_' + label + self.image_file_extension
        Rails.logger.info file_name
        next unless File.exist?(file_name)

        types = Gemgento::AssetType.find_by(product_attribute_set: product_attribute_set)

        unless types.is_a? Array
          types = [types]
        end

        product.assets << create_image(product, file_name, types, position, label)
        images_found = true
      end

      unless images_found
        self.import_errors << "WARNING: No images found for id:#{product.id}, sku: #{product.sku}"
      end
    end

    def create_image(product, file_name, types, position, label)
      image = Gemgento::Asset.new
      image.product = product
      image.attachment = File.open(file_name)
      image.position = position
      image.label = label

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
      configurable_product = Gemgento::Product.where(sku: sku).first_or_initialize

      if configurable_product.magento_id.nil?
        self.count_created += 1
      else
        self.count_created += 1
      end

      configurable_product.magento_type = 'configurable'
      configurable_product.sku = sku

      configurable_product.product_attribute_set = product_attribute_set
      configurable_product.status = @row[@headers.index('status').to_i].to_i
      configurable_product.store = store
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
      configurable_product.assets.destroy_all
      default_product = configurable_product.simple_products.first

      default_product.assets.each do |asset|
        asset_copy = Gemgento::Asset.new
        asset_copy.product = configurable_product
        asset_copy.attachment = File.open(asset.attachment.path(:original))
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