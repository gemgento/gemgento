module Gemgento
  class Asset < ActiveRecord::Base
    belongs_to :product
    has_and_belongs_to_many :asset_types, -> { uniq } , :join_table => 'gemgento_assets_asset_types'
    after_save :sync_local_to_magento
    before_destroy :delete_magento

    def set_types(asset_type_codes)
      self.asset_types.destroy_all

      # if there is only one category, the returned value is not interpreted array
      unless asset_type_codes.is_a? Array
        asset_type_codes = [Gemgento::Magento.enforce_savon_string(asset_type_codes)]
      end

      # loop through each return category and add it to the product if needed
      asset_type_codes.each do |asset_type_code|
        unless(asset_type_code.empty?)
          asset_type = Gemgento::AssetType.find_by(product_attribute_set_id: self.product.product_attribute_set_id, code: asset_type_code)
          self.asset_types << asset_type unless self.asset_types.include?(asset_type) # don't duplicate the asset types
        end
      end
    end

    private

    def sync_local_to_magento
      if self.sync_needed
        API::SOAP::Catalog::ProductAttributeMedia.create(self)
        self.sync_needed = false
        self.save
      end
    end

  end
end