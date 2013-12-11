module Gemgento
  module API
    module SOAP
      module Catalog
        class Product

          # Synchronize local database with Magento database
          def self.fetch_all(last_updated = nil, skip_existing = false)
            updates_made = false

            list(last_updated).each do |store_view|
              unless store_view == empty_product_list
                updates_made = true

                # enforce array
                unless store_view[:item].is_a? Array
                  store_view[:item] = [store_view[:item]]
                end

                store_view[:item].each do |basic_product_info|
                  next if skip_existing && Gemgento::Product.where(magento_id: basic_product_info[:product_id]).present?

                  attribute_set = Gemgento::ProductAttributeSet.where(magento_id: basic_product_info[:set]).first
                  fetch(basic_product_info[:product_id], attribute_set)
                end
              end
            end

            associate_simple_products_to_configurable_products if updates_made
          end

          def self.fetch(product_id, attribute_set)
            product_info = info(product_id, attribute_set)

            # update the product and grab the images
            product = sync_magento_to_local(product_info)
            Gemgento::API::SOAP::Catalog::ProductAttributeMedia.fetch(product)
          end

          def self.list(last_updated = nil)
            if last_updated.nil?
              message = {}
            else
              message = {
                  'filters' => {
                      'complex_filter' => {item: [
                          key: 'updated_at',
                          value: {
                              key: 'gt',
                              value: last_updated
                          }
                      ]}
                  }
              }
            end

            response = Gemgento::Magento.create_call(:catalog_product_list, message)
            if response.success? && !response.body_overflow[:store_view].nil?

              # enforce array
              unless response.body_overflow[:store_view].is_a? Array
                response.body_overflow[:store_view] = [response.body_overflow[:store_view]]
              end

              response.body_overflow[:store_view]
            else
              return []
            end
          end

          def self.info(product_id, attribute_set)
            additional_attributes = []
            attribute_set.product_attributes.each do |attribute|
              additional_attributes << attribute.code
            end

            message = {
                product: product_id,
                productIdentifierType: 'id',
                attributes: {
                    'additional_attributes' => {'item' => additional_attributes}
                }
            }
            response = Gemgento::Magento.create_call(:catalog_product_info, message)

            if response.success?
              return response.body[:info]
            end
          end

          # Create a new Product in Magento and set out magento_id
          def self.create(product)
            message = {
                type: product.magento_type,
                set: product.product_attribute_set.magento_id,
                sku: product.sku,
                product_data: compose_product_data(product),
                store_view: product.store.magento_id
            }
            response = Gemgento::Magento.create_call(:catalog_product_create, message)

            if response.success?
              product.magento_id = response.body[:result]
            else
              product.magento_id = nil
            end
          end

          # Update existing Magento Product
          def self.update(product)
            message = {product: product.magento_id, product_identifier_type: 'id', product_data: compose_product_data(product)}
            response = Gemgento::Magento.create_call(:catalog_product_update, message)

            return response.success?
          end

          def self.delete(product)
            message = { product: product.magento_id, product_identifier_type: 'id' }
            response = Gemgento::Magento.create_call(:catalog_product_delete, message)

            return response.success?
          end

          def self.check_magento(identifier, identifier_type, attribute_set)
            additional_attributes = []
            attribute_set.product_attributes.each do |attribute|
              additional_attributes << attribute.code
            end

            message = {
                product: identifier,
                productIdentifierType: identifier_type,
                attributes: {
                    'additional_attributes' => {'arr:string' => additional_attributes}
                }
            }

            response = Gemgento::Magento.create_call(:catalog_product_info, message)

            unless response.success?
              return Gemgento::Product.new
            else
              return sync_magento_to_local(response.body[:info])
            end
          end

          def self.visibility
            {
                'Not Visible Individually' => 1,
                'Catalog' => 2,
                'Search' => 3,
                'Catalog, Search' => 4,
                1 => 'Not Visible Individually',
                2 => 'Catalog',
                3 => 'Search',
                4 => 'Catalog, Search'
            }
          end

          def self.status
            {
                1 => true,
                2 => false,
                'Enabled' => true,
                'Disabled' => false
            }
          end

          def self.propagate_magento_deletions
            Gemgento::Product.not_deleted.where('magento_id NOT IN (?)', all_magento_product_ids).each do |product|
              product.mark_deleted!
            end
          end

          private

          def self.sync_magento_to_local(subject)
            product = Gemgento::Product.where(magento_id: subject[:product_id]).not_deleted.first_or_initialize
            product.magento_id = subject[:product_id]
            product.magento_type = subject[:type]
            product.sku = subject[:sku]
            product.sync_needed = false
            product.product_attribute_set = Gemgento::ProductAttributeSet.where(magento_id: subject[:set]).first
            product.store = Gemgento::Store.current
            product.save

            product.set_attribute_value('name', subject[:name])
            product.set_attribute_value('description', subject[:description])
            product.set_attribute_value('short_description', subject[:short_description])
            product.set_attribute_value('weight', subject[:weight])
            product.set_attribute_value('url_key', subject[:url_key])
            product.set_attribute_value('url_path', subject[:url_path])
            product.set_attribute_value('has_options', subject[:has_options])
            product.set_attribute_value('gift_message_available', subject[:gift_message_available])
            product.set_attribute_value('price', subject[:price])
            product.set_attribute_value('special_price', subject[:special_price])
            product.set_attribute_value('special_from_date', subject[:special_from_date])
            product.set_attribute_value('special_to_date', subject[:special_to_date])
            product.set_attribute_value('tax_class_id', subject[:tax_class_id])
            product.set_attribute_value('meta_title', subject[:meta_title])
            product.set_attribute_value('meta_keyword', subject[:meta_keyword])
            product.set_attribute_value('meta_description', subject[:meta_description])
            product.set_attribute_value('custom_design', subject[:custom_design])
            product.set_attribute_value('custom_layout_update', subject[:custom_layout_update])
            product.set_attribute_value('options_container', subject[:options_container])
            product.set_attribute_value('enable_googlecheckout', subject[:enable_googlecheckout])

            set_categories(subject[:categories][:item], product) if subject[:categories][:item]
            set_attribute_values_from_magento(subject[:additional_attributes][:item], product) if (subject[:additional_attributes] and subject[:additional_attributes][:item])

            product
          end

          def self.set_categories(magento_categories, product)
            product.categories.clear

            # if there is only one category, the returned value is not interpreted array
            unless magento_categories.is_a? Array
              magento_categories = [magento_categories]
            end

            # loop through each return category and add it to the product if needed
            magento_categories.each do |magento_category|
              category = Gemgento::Category.where(magento_id: magento_category).first
              product.categories << category unless product.categories.include?(category) # don't duplicate the categories
            end

            product.save
          end

          def self.set_attribute_values_from_magento(magento_attribute_values, product)
            magento_attribute_values.each do |attribute_value|

              if attribute_value[:key] == 'visibility'
                product.visibility = attribute_value[:value].to_i
                product.save
              elsif attribute_value[:key] == 'status'
                product.status = attribute_value[:value].to_i == 1 ? 1 : 0
                product.save
              else
                product.set_attribute_value(attribute_value[:key], attribute_value[:value])
              end

            end
          end

          def self.associate_simple_products_to_configurable_products
            Gemgento::Product.skip_callback(:save, :after, :sync_local_to_magento)

            Gemgento::Product.where(magento_type: 'configurable').each do |configurable_product|
              configurable_product.simple_products.clear
              configurable_product.simple_products = Gemgento::MagentoDB.associated_simple_products(configurable_product)
            end
          end

          def self.compose_product_data(product)
            product_data = {
                'name' => product.attribute_value('name'),
                'description' => product.attribute_value('description'),
                'short_description' => product.attribute_value('short_description'),
                'weight' => product.attribute_value('weight'),
                'status' => product.status ? 1 : 2,
                'categories' => {'item' => compose_categories(product)},
                'url_key' => product.attribute_value('url_key'),
                'price' => product.attribute_value('price'),
                'tax_class_id' => '2',
                'additional_attributes' => {'single_data' => {'item' => compose_attribute_values(product)}},
                'visibility' => product.visibility
            }

            unless product.simple_products.empty?
              product_data.merge!({'associated_skus' => {'item' => compose_associated_skus(product)}, 'price_changes' => compose_price_changes(product)})
            end

            product_data
          end

          def self.compose_categories(product)
            categories = []

            product.categories.each do |category|
              categories << "#{category.magento_id}"
            end

            categories
          end

          def self.compose_attribute_values(product)
            attributes = []

            product.product_attribute_values.each do |product_attribute_value|
              unless product_attribute_value.value.nil?
                attributes << {
                    'key' => product_attribute_value.product_attribute.code,
                    'value' => product_attribute_value.value
                }
              end
            end

            attributes << {
                key: 'gemgento_id',
                value: product.id
            }

            attributes
          end

          def self.compose_associated_skus(product)
            associated_skus = []

            product.simple_products.each do |simple_product|
              associated_skus << simple_product.sku
            end

            associated_skus
          end

          def self.compose_price_changes(product)
            price_changes = []

            product.configurable_attributes.each do |configurable_attribute|
              options = []

              configurable_attribute.product_attribute_options.where(store: Gemgento::Store.current).each do |attribute_option|
                options << {key: attribute_option.label, value: ''}
              end

              price_changes << {key: configurable_attribute.code, value: options}
            end

            [price_changes]
          end

          def self.empty_product_list
            {:'@soap_enc:array_type' => 'ns1:catalogProductEntity[0]', :'@xsi:type' => 'ns1:catalogProductEntityArray'}
          end

          def self.all_magento_product_ids
            magento_product_ids = []

            list.each do |store_view|
              unless store_view == empty_product_list

                # enforce array
                unless store_view[:item].is_a? Array
                  store_view[:item] = [store_view[:item]]
                end

                store_view[:item].each do |basic_product_info|
                  magento_product_ids << basic_product_info[:product_id] unless magento_product_ids.include? basic_product_info[:product_id]
                end
              end
            end

            return magento_product_ids
          end

        end
      end
    end
  end
end
