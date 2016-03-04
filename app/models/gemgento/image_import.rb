require 'spreadsheet'
require 'open-uri'

module Gemgento

  # @author Gemgento LLC
  class ImageImport < Import
    attr_accessor :product
    
    validates_with ImageImportValidator

    def default_options
      {
          image_labels: [],
          image_file_extensions: [],
          image_types: [],
          image_path: nil,
          store_id: nil,
          destroy_existing: false
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

    def store
      if options[:store_id].nil?
        nil
      else
        @store ||= Gemgento::Store.find(options[:store_id])
      end
    end

    def destroy_existing?
      options[:destroy_existing].to_bool
    end

    def process_row
      sku = value('sku')
      self.product = Product.not_deleted.find_by(sku: sku)
      return if self.product.nil?

      API::SOAP::Catalog::ProductAttributeMedia.fetch(self.product, store)
      destroy_existing_assets if destroy_existing?
      create_images
    end

    # Destroy all Assets associated with self.product.
    #
    # @return [Void]
    def destroy_existing_assets
      self.product.assets.where(store: store).find_each do |asset|
        begin
          asset.destroy
        rescue
          # just making sure we don't have a problem if file no longer exists
        end
      end
    end

    # Search for and create all possible images for a product.
    #
    # @return [Void]
    def create_images
      # find the correct image file name and path
      self.image_labels.each_with_index do |label, position|

        self.image_file_extensions.each do |extension|
          file_name = self.image_path + value('image') + '_' + label + extension
          next unless File.exist?(file_name)

          types = []

          unless self.image_types[position].nil?
            types = Gemgento::AssetType.where(product_attribute_set:  self.product.product_attribute_set, code: self.image_types[position])
          end

          unless types.is_a? Array
            types = [types]
          end

          create_image(file_name, types, position, label)
        end
      end

      # clear the cache
      Rails.cache.clear
    end

    # Create an image for the product.
    #
    # @param file_name [String]
    # @param types [Array(String)]
    # @param position [Integer]
    # @param label [String]
    # @return [Void]
    def create_image(file_name, types, position, label)
      asset = Asset.new
      asset.product = self.product
      asset.store = store
      asset.position = position
      asset.label = label
      asset.set_file(File.open(file_name))

      types.each do |type|
        asset.asset_types << type
      end

      asset.sync_needed = false
      asset.save

      asset.sync_needed = true

      unless asset.save
        self.process_errors << "Row #{current_row}: #{asset.errors[:base]}"
      end
    end
  end
end
