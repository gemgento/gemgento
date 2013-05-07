module Gemgento
  class Asset < ActiveRecord::Base
    include Gemgento::BaseHelper

    belongs_to :product

    def self.fetch_all(product)
      asset_response = Gemgento::Magento.create_call(:catalog_product_attribute_media_list, { product: product.magento_id, productIdentifierType: 'id' })

      unless asset_response[:result][:item].nil? # check if there are any options returned

        if asset_response[:result][:item].is_a? Array # multiple options returned

          asset_response[:result][:item].each do |asset|
            sync_magento_to_local(asset, product.id)
          end
        else # one option returned
          sync_magento_to_local(asset_response[:result][:item], product.id)
        end
      end
    end

    private

    def self.sync_magento_to_local(source, product_id)
      asset = Gemgento::Asset.find_or_initialize_by_product_id_and_url(product_id, source[:url])
      asset.url = source[:url]
      asset.position = source[:position]
      asset.label = source[:label]
      asset.file = ensure_string(source[:file])
      asset.product_id = product_id
      asset.save
    end
  end
end