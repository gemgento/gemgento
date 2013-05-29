module Gemgento
  class Asset < ActiveRecord::Base
    belongs_to :product
    has_and_belongs_to_many :asset_types, -> { uniq } , :join_table => 'gemgento_assets_asset_types'
    after_save :sync_local_to_magento
    before_destroy :delete_magento

    def self.fetch_all(product)
      asset_response = Gemgento::Magento.create_call(:catalog_product_attribute_media_list, { product: product.magento_id, productIdentifierType: 'id' })

      unless asset_response[:result][:item].nil? # check if there are any options returned

        if asset_response[:result][:item].is_a? Array # multiple options returned

          asset_response[:result][:item].each do |asset|
            sync_magento_to_local(asset, product)
          end
        else # one option returned
          sync_magento_to_local(asset_response[:result][:item], product)
        end
      end
    end

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
        create_magento
        self.sync_needed = false
        self.save
      end
    end

    def self.sync_magento_to_local(source, product)
      asset = Gemgento::Asset.find_or_initialize_by(product_id: product.id, url: source[:url])
      asset.url = source[:url]
      asset.position = source[:position]
      asset.label = Gemgento::Magento.enforce_savon_string(source[:label])
      asset.file = source[:file]
      asset.product = product
      asset.sync_needed = false
      asset.save

      asset.set_types(source[:types][:item])
    end

    def create_magento
      puts self.product.inspect
      message = { product: self.product.magento_id, data: compose_asset_entity_data, identifier_type: 'id' }
      create_response = Gemgento::Magento.create_call(:catalog_product_attribute_media_create, message)
      self.file = create_response[:result]
    end

    def delete_magento
      message = { product: self.product.magento_id, file: self.file, identifier_type: 'id' }
      remove_response = Gemgento::Magento.create_call(:catalog_product_attribute_media_remove, message)
    end

    def compose_asset_entity_data
      asset_entity = {
        file: compose_file_entity,
        label: self.label,
        position: self.position,
        types: { item: compose_types }
      }

      asset_entity
    end

    def compose_file_entity
      file_name = self.url.split('/')[-1]

      file_entity = {
        content: Base64.encode64(File.open(self.url).read),
        mime: MIME::Types.type_for(file_name).first.content_type
      }

      file_entity
    end

    def compose_types
      types = []

      self.asset_types.each do |asset_type|
        types << asset_type.code
      end

      types
    end
  end
end