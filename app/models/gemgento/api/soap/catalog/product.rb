module Gemgento
  module API
    module SOAP
      module Catalog
        class Product

          # Synchronize local database with Magento database
          def self.fetch_all
            list.each do |store_view|

              # enforce array
              unless store_view[:item].is_a? Array
                store_view[:item] = [store_view][:item]
              end

              store_view[:item].each do |product|
                attribute_set = Gemgento::ProductAttributeSet.find_by(magento_id: product[:set])
                product_info = info(product[:product_id], attribute_set)
                sync_magento_to_local(product_info)
              end
            end
          end

          def self.list
            response = Gemgento::Magento.create_call(:catalog_product_list)

            # enforce array
            unless response[:store_view].is_a? Array
              response[:store_view] = [response[:store_view]]
            end

            response[:store_view]
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
                    'additional_attributes' => { 'item' => additional_attributes }
                }
            }
            response = Gemgento::Magento.create_call(:catalog_product_info, message)
            response[:info]
          end

          # Create a new Product in Magento and set out magento_id
          def self.create(product)
            message = {
                type: product.magento_type,
                set: product.product_attribute_set.magento_id,
                sku: product.sku,
                productData: compose_product_data(product),
                storeView: product.store.magento_id
            }
            create_response = Gemgento::Magento.create_call(:catalog_product_create, message)
            product.magento_id = create_response[:result]
          end

          # Update existing Magento Product
          def self.update(product)
            message = { product: product.magento_id, product_identifier_type: 'id', product_data: compose_product_data(product) }
            Gemgento::Magento.create_call(:catalog_product_update, message)
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
                    'additional_attributes' => { 'arr:string' => additional_attributes }
                }
            }

            product_info_response = Gemgento::Magento.create_call(:catalog_product_info, message)

            if product_info_response.nil?
              Gemgento::Product.new
            else
              sync_magento_to_local(product_info_response[:info])
            end
          end

          private

          def self.sync_magento_to_local(subject)
            product = Gemgento::Product.find_or_initialize_by(magento_id: subject[:product_id])
            product.magento_id = subject[:product_id]
            product.magento_type = subject[:type]
            product.sku = subject[:sku]
            product.sync_needed = false
            product.product_attribute_set = Gemgento::ProductAttributeSet.find_by(magento_id: subject[:set])
            product.store = Gemgento::Store.first
            product.save

            product.set_attribute_value('name', subject[:name])
            product.set_attribute_value('description', subject[:description])
            product.set_attribute_value('short_description', subject[:short_description])
            product.set_attribute_value('weight', subject[:weight])
            product.set_attribute_value('status', subject[:status])
            product.set_attribute_value('url_key', subject[:url_key])
            product.set_attribute_value('url_path', subject[:url_path])
            product.set_attribute_value('visibility', subject[:visibility])
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
            # if there is only one category, the returned value is not interpreted array
            unless magento_categories.is_a? Array
              magento_categories = [magento_categories]
            end

            # loop through each return category and add it to the product if needed
            magento_categories.each do |magento_category|
              category = Gemgento::Category.find_by(magento_id: magento_category)
              product.categories << category unless product.categories.include?(category) # don't duplicate the categories
            end

            product.save
          end

          def self.set_attribute_values_from_magento(magento_attribute_values, product)
            magento_attribute_values.each do |attribute_value|
              product.set_attribute_value(attribute_value[:key], attribute_value[:value])
            end
          end

          def self.associate_simple_products_to_configurable_products
            Gemgento::Product.where(magento_type: 'configurable').each do |configurable_product|
              configurable_product.simple_products = Gemgento::MagentoDB.associated_simple_products(configurable_product)
            end
          end

          def self.compose_product_data(product)
            product_data = {
                'name' => product.attribute_value('name'),
                'description' => product.attribute_value('description'),
                'short_description' => product.attribute_value('short_description'),
                'weight' => product.attribute_value('weight'),
                'status' => product.attribute_value('status'),
                'categories' => { 'item' => compose_categories(product) },
                'url_key' => product.attribute_value('url_key'),
                'price' => product.attribute_value('price'),
                'additional_attributes' => { 'single_data' => { 'item' => compose_attribute_values(product) }}
            }

            unless product.simple_products.empty?
              product_data.merge!({ 'associated_skus' => { 'item' => compose_associated_skus(product) }, 'price_changes' => compose_price_changes(product) })
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

              configurable_attribute.product_attribute_options.each do |attribute_option|
                options << { key: attribute_option.label, value: ''}
              end

              price_changes << { key: configurable_attribute.code, value: options }
            end

            [price_changes]
          end

        end
      end
    end
  end
end