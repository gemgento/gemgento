module Gemgento
  module API
    module SOAP
      module Catalog
        class ProductAttributeSet

          # Pull all Magento ProductAttributeSet data into Gemgento.
          #
          # @return [Void]
          def self.fetch_all
            response = list

            if response.success?
              response.body[:result][:item].each do |product_attribute_set|
                sync_magento_to_local(product_attribute_set)
              end
            end
          end

          # Get a list of ProductAttributeSets from Magento.
          #
          # @return [Gemgento::MagentoResponse]
          def self.list
            response = MagentoApi.create_call(:catalog_product_attribute_set_list)

            if response.success?
              response.body[:result][:item] = [response.body[:result][:item]] unless response.body[:result][:item].is_a? Array
            end

            return response
          end

          # Create a new product attribute set in Magento
          def self.create
            # TODO: create a new product attribute set on Magento
          end

          # Update existing Magento product attribute set
          def self.update
            # TODO: update a product attribute set on Magento
          end

          def self.attribute_add
            # TODO: add an attribute to a set on Magento
          end

          def self.attribute_remove
            # TODO: remove an attribute from a set on Magento
          end

          def self.group_add
            # TODO: add a new group for attributes in the set on Magento
          end

          def self.group_remove
            # TODO: remove a group of attributes in the set on Magento
          end

          def self.group_rename
            # TODO: rename a group in the set on Magento
          end

          private

          # Save Magento product attribute set to local.
          #
          # @return [Void]
          def self.sync_magento_to_local(source)
            product_attribute_set = ::Gemgento::ProductAttributeSet.where(magento_id: source[:set_id]).first_or_initialize
            product_attribute_set.magento_id = source[:set_id]
            product_attribute_set.name = source[:name]
            product_attribute_set.sync_needed = false
            product_attribute_set.save
          end

        end
      end
    end
  end
end