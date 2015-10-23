require 'open-uri'

module Gemgento

  # @author Gemgento LLC
  class Asset < ActiveRecord::Base
    belongs_to :product
    belongs_to :store
    belongs_to :asset_file

    has_and_belongs_to_many :asset_types, join_table: 'gemgento_assets_asset_types'

    validates :asset_file, :product_id, :store_id, presence: true
    validates_uniqueness_of :product_id, scope: [:asset_file_id, :store_id, :file]

    before_save :create_magento_product_attribute_media, if: -> { sync_needed? && file.blank? }
    before_save :update_magento_product_attribute_media, if: -> { sync_needed? && !file.blank? }

    after_save :touch_product

    before_destroy :delete_magento, :destroy_file

    default_scope -> { includes(:asset_file).order(:position).references(:asset_file) }

    # Associate an image file with the Asset.  If the same file is already associated to a related Asset in a
    # different store, then the Asset will be associated with the existing AssetFile.
    #
    # @param file [File, TempFile] a file to be associated with the Asset
    # @return [void]
    def set_file(file)
      matching_file = nil
      matching_asset = nil

      self.product.assets.each do |asset|
        next if asset.asset_file.nil?
        next if asset.store == self.store && asset.id != self.id # don't compare AssetFiles from the same store unless it's the same Asset

        if File.exist?(asset.asset_file.file.path(:original)) && FileUtils.compare_file(asset.asset_file.file.path(:original), file)
          matching_file = asset.asset_file
          matching_asset = asset
          break
        end
      end

      if matching_file.nil?
        begin
          matching_file = AssetFile.new
          matching_file.file = file
          matching_file.save
        rescue
          matching_file = nil
        end

        matching_asset = Asset.new
      end

      self.asset_file = matching_file
      self.file = matching_asset.file if self.file.blank? && !matching_asset.file.blank?
    end

    # Return the image file associated with the Asset.
    #
    # @return [Paperclip::Attachment, nil]
    def image
      if self.asset_file.nil?
        nil
      else
        self.asset_file.file
      end
    end

    # Associate AssetTypes to the Asset.
    #
    # @param asset_type_codes [Array(String)] asset type codes
    # @return [void]
    def set_types_by_codes(asset_type_codes)
      applied_asset_types = []

      # loop through each return category and add it to the product if needed
      asset_type_codes.each do |asset_type_code|
        next if asset_type_code.blank?

        asset_type = AssetType.find_by(
            product_attribute_set: self.product.product_attribute_set,
            code: asset_type_code,
        )
        next if asset_type.nil?

        self.asset_types << asset_type unless self.asset_types.include? asset_type # don't duplicate the asset types
        applied_asset_types << asset_type.id

        # an AssetType can only be associated to one asset for every
        asset_type.assets.where(product_id: self.product_id, store_id: self.store_id).where('gemgento_assets.id != ?', self.id).find_each do |asset|
          asset.asset_types.destroy(asset_type)
        end
      end

      # destroy any asset type associations that were not in the list
      self.asset_types.delete(AssetType.where('id NOT IN (?)', applied_asset_types))
    end

    # Find a products asset by the AssetType code
    #
    # @param product [Product]
    # @param code [String]
    # @param store [Integer, nil]
    # @return [Asset, nil]
    def self.find_by_code(product, code, store = nil)
      store = Store.current if store.nil?
      asset_type = AssetType.find_by(code: code, product_attribute_set_id: product.product_attribute_set_id)
      raise "Unknown AssetType code for given product's ProductAttributeSet" if asset_type.nil?

      return asset_type.assets.find_by(product_id: product.id, store_id: store.id)
    end

    def as_json(options = {})
      result = super

      result[:styles] = {'original' => self.image.url(:original)}

      self.image.styles.keys.to_a.each do |style|
        result[:styles][style] = self.image.url(style.to_sym)
      end

      result[:types] = []
      self.asset_types.each do |asset_type|
        result[:types] << asset_type.code unless result[:types].include? asset_type.code
      end

      return result
    end

    private

    # Create an associated ProductAttributeMedia in Magento.
    #
    # @return [Boolean]
    def create_magento_product_attribute_media
      response = API::SOAP::Catalog::ProductAttributeMedia.create(self)

      if response.success?
        self.file = response.body[:result]
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Create an associated ProductAttributeMedia in Magento.
    #
    # @return [Boolean]
    def update_magento_product_attribute_media
      response = API::SOAP::Catalog::ProductAttributeMedia.update(self)

      if response.success?
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    # Destroy the Asset in Magento.  This is a before destroy callback.
    #
    # @return [void]
    def delete_magento
      if !self.file.blank? && (!self.asset_file.nil? && self.asset_file.assets.where('gemgento_assets.id != ?', self.id).empty?)
        API::SOAP::Catalog::ProductAttributeMedia.remove(self)
      end

      self.asset_types.clear
    end

    # Destroy the associated AssetFile if it is not used by other Assets.  This is a before destroy callback.
    #
    # @return [void]
    def destroy_file
      if !self.asset_file.nil? && self.asset_file.assets.where('gemgento_assets.id != ?', self.id).empty?
        self.asset_file.destroy
      end
    end

    # Set product updated_at to now if the Asset has been changed.  This happens asynchronously using Sidekiq and is
    # necessary for cache invalidation.  It is called as the after save callback.
    #
    # @return [void]
    def touch_product
      TouchProduct.perform_async([self.product.id]) if self.changed?
    end

  end
end