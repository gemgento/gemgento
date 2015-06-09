module Gemgento
  module API
    module SOAP
      module Catalog
        class ProductAttributeMedia

          def self.fetch_all
            ::Gemgento::Store.all.each do |store|
              ::Gemgento::Product.active.each do |product|
                fetch(product, store)
              end
            end
          end

          def self.fetch(product, store = nil)
            store = ::Gemgento::Store.current if store.nil?
            response = list(product, store)

            if response.success?
              response.body[:result][:item].each do |product_attribute_media|
                sync_magento_to_local(product_attribute_media, product, store)
              end
            end
          end

          def self.fetch_all_media_types
            ::Gemgento::ProductAttributeSet.all.each do |product_attribute_set|
              response = types(product_attribute_set)

              if response.success?
                response.body[:result][:item].each do |media_type|
                  sync_magento_media_type_to_local(media_type, product_attribute_set)
                end
              end
            end
          end

          def self.list(product, store)
            message = {
                product: product.magento_id,
                identifier_type: 'id',
                store_view: store.magento_id
            }
            response = ::Gemgento::MagentoApi.create_call(:catalog_product_attribute_media_list, message)

            if response.success?
              if response.body[:result][:item].nil?
                response.body[:result][:item] = []
              elsif !response.body[:result][:item].is_a? Array
                response.body[:result][:item] = [response.body[:result][:item]]
              end
            end

            return response
          end

          def self.info

          end

          # Create a Product Attribute Media in Magento.
          #
          # @param asset [Gemgento::Asset]
          # @return [Gemgento::MagentoResponse]
          def self.create(asset)
            message = {
                product: asset.product.magento_id,
                data: compose_asset_entity_data(asset, true),
                identifier_type: 'id',
                store_view: asset.store.magento_id
            }
            ::Gemgento::MagentoApi.create_call(:catalog_product_attribute_media_create, message)
          end

          # Update a Product Attribute Media in Magento.
          #
          # @param asset [Gemgento::Asset]
          # @return [Gemgento::MagentoResponse]
          def self.update(asset)
            message = {
                product: asset.product.magento_id,
                file: asset.file,
                data: compose_asset_entity_data(asset, false),
                identifier_type: 'id',
                store_view: asset.store.magento_id
            }
            ::Gemgento::MagentoApi.create_call(:catalog_product_attribute_media_update, message)
          end

          # Remove Product Attribute Media in Magento.
          #
          # @param asset [Gemgento::Asset]
          # @return [Gemgento::MagentoResponse]
          def self.remove(asset)
            message = { product: asset.product.magento_id, file: asset.file, identifier_type: 'id' }
            ::Gemgento::MagentoApi.create_call(:catalog_product_attribute_media_remove, message)
          end

          # Get Product Attribute Media Types from Magento.
          #
          # @param product_attribute_set [Gemgento::ProductAttributeSet]
          # @return [Gemgento::MagnetoRepsonse]
          def self.types(product_attribute_set)
            response = ::Gemgento::MagentoApi.create_call(:catalog_product_attribute_media_types, {set_id: product_attribute_set.magento_id})

            if response.success? &&
              if response.body[:result][:item].nil?
                response.body[:result][:item] = []
              elsif !response.body[:result][:item].is_a?(Array)
                response.body[:result][:item] = [response.body[:result][:item]]
              end
            end

            return response
          end

          private

          # Save Magento product attribute set to local
          def self.sync_magento_to_local(source, product, store)
            return false unless ::Gemgento::AssetFile.valid_url(source[:url])

            asset = ::Gemgento::Asset.find_or_initialize_by(product_id: product.id, file: source[:file], store_id: store.id)
            asset.url = source[:url]
            asset.position = source[:position]
            asset.label = ::Gemgento::MagentoApi.enforce_savon_string(source[:label])
            asset.file = source[:file]
            asset.product = product
            asset.sync_needed = false
            asset.store = store
            asset.set_file(URI.parse(source[:url]))
            asset.save

            # assign AssetTypes
            asset_type_codes = source[:types][:item]
            asset_type_codes = [::Gemgento::MagentoApi.enforce_savon_string(asset_type_codes)] unless asset_type_codes.is_a? Array
            asset.set_types_by_codes(asset_type_codes)
          end

          def self.sync_magento_media_type_to_local(source, product_attribute_set)
            asset_type = ::Gemgento::AssetType.find_or_initialize_by(product_attribute_set: product_attribute_set, code: source[:code])
            asset_type.scope = source[:scope]
            asset_type.save
          end

          def self.compose_asset_entity_data(asset, include_file = true)
            asset_entity = {
                label: asset.label,
                position: asset.position,
                types: {item: compose_types(asset)},
                exclude: '0'
            }

            if include_file
              asset_entity[:file] = compose_file_entity(asset.asset_file)
            end

            asset_entity
          end

          def self.compose_file_entity(asset_file)
            if asset_file.file.url(:original) =~ URI::regexp
              content = open(asset_file.file.url(:original)).read
            else
              content = File.open(asset_file.file.path(:original)).read
            end

            file_entity = {
                content: Base64.encode64(content),
                mime: asset_file.file_content_type
            }

            file_entity
          end

          def self.compose_types(asset)
            types = []

            asset.asset_types.each do |asset_type|
              types << asset_type.code
            end

            types
          end

        end
      end
    end
  end
end