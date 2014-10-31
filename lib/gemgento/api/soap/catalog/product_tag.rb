module Gemgento
  module API
    module SOAP
      module Catalog
        class ProductTag

          # Fetch all product tags from Magento.
          #
          # @return [Void]
          def self.fetch_all
            Product.not_deleted.where(magento_id: [391]).each do |product|
              product.stores.each do |store|
                list_response = list product, store

                if list_response.success?

                  list_response.body[:result][:item].each do |tag|
                    info_response = info tag[:tag_id], store

                    if info_response.success?
                      sync_magento_to_local tag[:tag_id], info_response.body[:result], store
                    end
                  end
                end
              end
            end
          end

          # Retrieve a list of tags related to a product and store.
          #
          # @param product [Product]
          # @param store [Store]
          # @return [Gemgento::MagentoResponse]
          def self.list(product, store)
            message = {
                product_id: product.magento_id,
                store: store.magento_id
            }
            response = Magento.create_call(:catalog_product_tag_list, message)

            if response.success?
              response.body[:result][:item] = [response.body[:result][:item]] unless response.body[:result][:item].is_a? Array
            end

            return response
          end

          # Retrieve info on a specific tag.
          #
          # @param magento_tag_id [Gemgento::Integer]
          # @param store [Gemgento::Store]
          # @return [Gemgento::MagentoResponse]
          def self.info(magento_tag_id, store)
            message = {
                tag_id: magento_tag_id,
                store: store.magento_id
            }
            Magento.create_call(:catalog_product_tag_info, message)
          end

          # Sync a Magento tag to Gemgento.
          #
          # @param magento_tag_id [Integer]
          # @param source [Hash]
          # @param store [Store]
          def self.sync_magento_to_local(magento_tag_id, source, store)
            tag = Tag.find_or_initialize_by(magento_id: magento_tag_id)
            tag.name = source[:name]
            tag.sync_needed = false
            tag.save

            store_tag = StoreTag.find_or_initialize_by(store: store, tag: tag)
            store_tag.base_popularity = source[:base_popularity]
            store_tag.save

            associate_products(tag, source[:products][:item]) if source[:products][:item]
          end

          # Associate a tag using a set of magento product ids.
          #
          # @param tag [Tag]
          # @param source_product_ids [Hash, Array(Hash)]
          # @return [Void]
          def self.associate_products(tag, source_product_ids)
            product_ids = []
            source_product_ids = [source_product_ids] unless source_product_ids.is_a? Array

            source_product_ids.each do |product_key|
              Product.unscoped do
                if product = Product.not_deleted.find_by(magento_id: product_key[:key])
                  tag.products << product unless tag.products.include? product
                  product_ids << product.id
                end
              end
            end

            tag.products.where('gemgento_products.id NOT IN (?)', product_ids).destroy_all
          end

          # Add tags to a product.
          #
          # @param tags [Array(Tag)]
          # @param products [Product]
          # @param store [Store]
          # @param user [User]
          # @return [Gemgento::MagentoResponse]
          def self.add(tags, product, store, user = nil)
            message = {
                tag: "'#{tags.map(&:name).join("', '")}'",
                product_id: product.magento_id,
                store: store.magento_id
            }
            message[:customer_id] = user.magento_id unless user.nil?

            response = Magento.create_call(:catalog_product_tag_info, message)

            if response.success?
              response.body[:result][:item] = [response.body[:result][:item]] unless response.body[:result][:item].is_a?(Array)
            end

            return response
          end

          # Manage a tag, this will create/update a tag with absolute values.
          #
          # @param tag [Tag]
          # @param store [Store]
          # @return [Gemgento::MagentoResponse]
          def self.manage(tag, store)
            message = {
                name: tag.name,
                status: tag.status,
                base_popularity: tag.base_popularity(store),
                product_ids: {item: tag.products.map(&:magento_id)},
                store: store.magento_id
            }
            message[:tag_id] = tag.magento_id unless tag.magento_id.nil?

            Magento.create_call(:catalog_product_tag_manage, message)
          end

        end
      end
    end
  end
end