module Gemgento
  module API
    module SOAP
      module Catalog
        class ProductAttribute

          def self.fetch_all
            ::Gemgento::ProductAttributeSet.all.each do |product_attribute_set|
              list(product_attribute_set).each do |product_attribute|
                sync_magento_to_local(info(product_attribute[:attribute_id]), product_attribute_set)
              end
            end
          end

          def self.fetch(attribute_id, attribute_set)
            attribute_info = info(attribute_id)
            sync_magento_to_local(attribute_info, attribute_set)
          end

          def self.fetch_all_options(product_attribute)
            # add attribute options if there are any
            Store.all.each do |store|
              options(product_attribute.magento_id, store).each_with_index do |attribute_option, index|
                label = Magento.enforce_savon_string(attribute_option[:label])
                value = Magento.enforce_savon_string(attribute_option[:value])

                product_attribute_option = ProductAttributeOption.where(product_attribute: product_attribute, label: label, value: value, store: store).first_or_initialize
                product_attribute_option.label = label
                product_attribute_option.value = value
                product_attribute_option.product_attribute = product_attribute
                product_attribute_option.order = index
                product_attribute_option.store = store
                product_attribute_option.sync_needed = false
                product_attribute_option.save
              end
            end
          end

          def self.list(product_attribute_set)
            response = Magento.create_call(:catalog_product_attribute_list, {set_id: product_attribute_set.magento_id})

            if response.success?
              unless response.body[:result][:item].is_a? Array
                response.body[:result][:item] = [response.body[:result][:item]]
              end

              response.body[:result][:item]
            end
          end

          def self.info(attribute_id)
            response = Magento.create_call(:catalog_product_attribute_info, {attribute: attribute_id})

            if response.success?
              response.body[:result]
            end
          end

          def self.options(product_attribute_id, store)
            message = {
                attributeId: product_attribute_id,
                storeView: store.magento_id
            }
            response = Magento.create_call(:catalog_product_attribute_options, message)

            if response.success?
              if response.body[:result][:item].nil?
                response.body[:result][:item] = []
              end

              unless response.body[:result][:item].is_a? Array
                response.body[:result][:item] = [response.body[:result][:item]]
              end

              response.body[:result][:item]
            end
          end

          def self.types
            # TODO: Create types API call
          end

          def self.create(product_attribute)
            # TODO: create a new product attribute set on Magento
          end

          def self.update(product_attribute)
            # TODO: update a product attribute set on Magento
          end

          def self.add_option(product_attribute_option, product_attribute)
            message = {attribute: product_attribute.magento_id, data: {
                label: {item: [{'store_id' => {item: Store.all.map { |s| s.magento_id.to_s } << 0}, value: product_attribute_option.label}]},
                order: '0',
                'is_default' => '0'
            }}

            response = Magento.create_call(:catalog_product_attribute_add_option, message)
            fetch_all_options(product_attribute) if response.success?
          end

          def self.remove_option
            # TODO: update a product attribute set on Magento
          end

          private

          # Save Magento product attribute set to local
          def self.sync_magento_to_local(source, product_attribute_set)
            unless ::Gemgento::ProductAttribute.ignored.include?(source[:attribute_code])
              product_attribute = ::Gemgento::ProductAttribute.find_or_initialize_by(magento_id: source[:attribute_id])
              product_attribute.magento_id = source[:attribute_id]
              product_attribute.product_attribute_sets << product_attribute_set unless product_attribute.product_attribute_sets.include? product_attribute_set
              product_attribute.code = source[:attribute_code]
              product_attribute.frontend_input = source[:frontend_input]
              product_attribute.scope = source[:scope]
              product_attribute.default_value = source[:default_value] == {:'@xsi:type' => 'xsd:string'} ? nil : source[:default_value]
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

              fetch_all_options(product_attribute) if product_attribute.frontend_input == 'select'
            end
          end
        end
      end
    end
  end
end