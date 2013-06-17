module Gemgento
  module API
    module SOAP
      module Catalog
        class ProductAttribute

          def self.fetch_all(product_attribute_set)
            list(product_attribute_set).each do |product_attribute|
              sync_magento_to_local(info(product_attribute[:attribute_id], product_attribute_set), product_attribute_set)
            end
          end

          def self.list(product_attribute_set)
            response = Gemgento::Magento.create_call(:catalog_product_attribute_list, { set_id: product_attribute_set.magento_id })

            unless response[:result][:item].is_a? Array
              response[:result][:item] = [response[:result][:item]]
            end

            response[:result[:item]]
          end

          def self.info(attribute_id, product_attribute_set)
            response = Gemgento::Magento.create_call(:catalog_product_attribute_info, {attribute: id})
            response[:result]
          end

          def self.options(product_attribute_id)
            response = Gemgento::Magento.create_call(:catalog_product_attribute_options, {attributeId: product_attribute_id})

            if attribute_options_response[:result][:item].nil?
              return []
            else
              unless attribute_options_response[:result][:item].is_a? Array
                attribute_options_response[:result][:item] = [attribute_options_response[:result][:item]]
              end

              return attribute_options_response[:result][:item]
            end
          end

          def self.types

          end

          def self.create
            # TODO: create a new product attribute set on Magento
          end

          def self.update
            # TODO: update a product attribute set on Magento
          end

          def self.add_option(product_attribute_option, product_attribute)
            message = { attribute: product_attribute.magento_id, data: {
                label: { item: [{ 'store_id' => { item: [0,1] }, value: product_attribute_option.label }] },
                order: '0',
                'is_default' => '0'
            }}
            Gemgento::Magento.create_call(:catalog_product_attribute_add_option, message)
          end

          def self.remove_option
            # TODO: update a product attribute set on Magento
          end

          private

          # Push local product attribute set changes to Magento
          def self.sync_local_to_magento(product_attribute)
            if self.sync_needed
              if !self.magento_id
                create_magento
              else
                update_magento
              end

              self.sync_needed = false
              self.save
            end
          end

          # Save Magento product attribute set to local
          def self.sync_magento_to_local(source, product_attribute_set)
            product_attribute = ProductAttribute.find_or_initialize_by(magento_id: source[:attribute_id])
            product_attribute.magento_id = source[:attribute_id]
            product_attribute.product_attribute_set = product_attribute_set
            product_attribute.code = source[:attribute_code]
            product_attribute.frontend_input = source[:frontend_input]
            product_attribute.scope = source[:scope]
            product_attribute.is_unique = source[:is_unique]
            product_attribute.is_required = source[:is_required]
            product_attribute.is_configurable = source[:is_configurable]
            product_attribute.is_searchable = source[:is_searchable]
            product_attribute.is_visible_in_advanced_search = source[:is_visible_in_advanced_search]
            product_attribute.is_comparable = source[:is_comparable]
            product_attribute.is_used_for_promo_rules = source[:is_used_for_promo_rules]
            product_attribute.is_visible_on_front = source[:is_visible_on_front]
            product_attribute.used_in_product_listing = source[:used_in_product_listing]
            product_attribute.sync_needed = false
            product_attribute.save

            # add attribute options if there are any
            options(product_attribute.magento_id).each do |attribute_option|
              label = Gemgento::Magento.enforce_savon_string(attribute_option[:label])
              value = Gemgento::Magento.enforce_savon_string(attribute_option[:value])

              product_attribute_option = Gemgento::ProductAttributeOption.find_or_initialize_by(product_attribute: product_attribute, label: label)
              product_attribute_option.label = label
              product_attribute_option.value = value
              product_attribute_option.product_attribute = product_attribute
              product_attribute_option.sync_needed = false
              product_attribute_option.save
            end
          end

        end
      end
    end
  end
end