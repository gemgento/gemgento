module Gemgento
  class Asset < ActiveRecord::Base
    belongs_to :product
    has_and_belongs_to_many :asset_types, -> { uniq } , :join_table => 'gemgento_assets_asset_types'
    after_save :sync_local_to_magento
    before_destroy :delete_magento

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