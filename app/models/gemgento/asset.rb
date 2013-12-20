require 'open-uri'

module Gemgento
  class Asset < ActiveRecord::Base
    belongs_to :product
    belongs_to :store
    belongs_to :asset_file

    has_and_belongs_to_many :asset_types, -> { uniq }, join_table: 'gemgento_assets_asset_types'

    after_save :sync_local_to_magento
    after_save :touch_product

    before_destroy :delete_magento

    default_scope -> { order(:position) }

    def set_file(file)
      raise 'Asset does not have an associated product.' if self.product.nil?

      matching_file = nil

      self.product.assets.each do |asset|
        if !asset.asset_file.nil? && FileUtils.compare_file(asset.asset_file.file.path(:original), file)
          matching_file = asset.asset_file
          break
        end
      end

      if matching_file.nil?
        begin
          matching_file = AssetFile.new
          matching_file.file = open(file_path)
          matching_file.save
        rescue
          matching_file = nil
        end
      end

      self.asset_file = matching_file
    end

    private

    def sync_local_to_magento
      if self.sync_needed
        API::SOAP::Catalog::ProductAttributeMedia.create(self)
        self.sync_needed = false
        self.save
      end
    end

    def delete_magento
      unless self.file.nil?
        API::SOAP::Catalog::ProductAttributeMedia.remove(self)
      end

      self.asset_types.clear
    end

    def touch_product
      self.product.update(updated_at: Time.now) if self.changed?
    end

  end
end