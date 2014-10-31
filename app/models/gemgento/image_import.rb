require 'spreadsheet'
require 'open-uri'

module Gemgento
  class ImageImport < ActiveRecord::Base
    include ActiveModel::Validations
    belongs_to :store

    has_attached_file :spreadsheet

    serialize :import_errors, Array
    serialize :image_labels, Array
    serialize :image_file_extensions, Array
    serialize :image_types, Array

    attr_accessor :image_labels_raw
    attr_accessor :image_file_extensions_raw
    attr_accessor :image_types_raw

    validates_attachment_content_type :spreadsheet, content_type: ['application/vnd.ms-excel']
    validates :image_file_extensions, :image_labels, :image_path, presence: true
    validates_with ImageImportValidator

    after_commit :process

    def self.is_active?
      ImageImport.where(is_active: true).count > 0
    end

    def process
      if self.spreadsheet.url =~ URI::regexp
        @worksheet = Spreadsheet.open(open(self.spreadsheet.url)).worksheet(0)
      else
        @worksheet = Spreadsheet.open(self.spreadsheet.path).worksheet(0)
      end

      @headers = get_headers

      1.upto @worksheet.last_row_index do |index|
        puts "Working on row #{index}"
        @row = @worksheet.row(index)
        @product = Product.not_deleted.find_by(sku: @row[@headers.index('sku').to_i].to_s.strip)
        API::SOAP::Catalog::ProductAttributeMedia.fetch(@product, self.store) # make sure we know about all existing images

        destroy_existing_assets if self.destroy_existing
        create_images
      end

      ImageImport.skip_callback(:commit, :after, :process)
      self.save validate: false
      ImageImport.set_callback(:commit, :after, :process)
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

    def destroy_existing_assets
      @product.assets.where(store: self.store).find_each do |asset|
        begin
          asset.destroy
        rescue
          # just making sure we don't have a problem if file no longer exists
        end
      end
    end

    def get_headers
      accepted_headers = []

      @worksheet.row(0).each do |h|
        unless h.nil?
          accepted_headers << h.downcase.gsub(' ', '_').strip
        end
      end

      accepted_headers
    end

    def create_images
      # find the correct image file name and path
      self.image_labels.each_with_index do |label, position|

        self.image_file_extensions.each do |extension|
          file_name = self.image_path + @row[@headers.index('image').to_i].to_s.strip + '_' + label + extension
          next unless File.exist?(file_name)

          types = []

          unless self.image_types[position].nil?
            types = AssetType.where('product_attribute_set_id = ? AND code IN (?)', @product.product_attribute_set.id, self.image_types[position].split(',').map(&:strip))
          end

          unless types.is_a? Array
            types = [types]
          end

          create_image(file_name, types, position, label)
        end
      end
    end

    def create_image(file_name, types, position, label)
      asset = Asset.new
      asset.product = @product
      asset.store = self.store
      asset.position = position
      asset.label = label
      asset.set_file(File.open(file_name))

      types.each do |type|
        asset.asset_types << type
      end

      asset.sync_needed = false
      asset.save

      asset.sync_needed = true
      asset.save
    end
  end
end