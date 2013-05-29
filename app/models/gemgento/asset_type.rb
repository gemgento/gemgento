module Gemgento
  class AssetType < ActiveRecord::Base
    belongs_to :product_attribute_set
    has_and_belongs_to_many :assets, -> { uniq } , :join_table => 'gemgento_assets_asset_types'

    def self.fetch_all(product_attribute_set)
      asset_type_response = Gemgento::Magento.create_call(:catalog_product_attribute_media_types, { set_id: product_attribute_set.magento_id })

      unless asset_type_response[:result][:item].nil? # check if there are any options returned

        if asset_type_response[:result][:item].is_a? Array # multiple options returned

          asset_type_response[:result][:item].each do |asset_type|
            sync_magento_to_local(asset_type, product_attribute_set)
          end
        else # one option returned
          sync_magento_to_local(asset_type_response[:result][:item], product_attribute_set)
        end
      end
    end

    private

    def self.sync_magento_to_local(source, product_attribute_set)
      asset_type = Gemgento::AssetType.find_or_initialize_by_product_attribute_set_id_and_code(product_attribute_set.id, source[:url])
      asset_type.code = source[:code]
      asset_type.scope = source[:scope]
      asset_type.product_attribute_set = product_attribute_set
      asset_type.save
    end
  end
end