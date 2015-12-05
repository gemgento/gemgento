module Gemgento
  module API
    module SOAP
      module Catalog
        class Product

          # Synchronize local database with Magento database
          def self.fetch_all(last_updated = nil, skip_existing = false)
            Store.all.each do |store|
              response = list(store, last_updated)

              if response.success?
                response.body_overflow[:store_view].each do |product_list|
                  unless product_list == empty_product_list

                    # enforce array
                    product_list[:item] = [product_list[:item]] unless product_list[:item].is_a? Array

                    product_list[:item].each do |basic_product_info|
                      if skip_existing
                        product = ::Gemgento::Product.find_by(magento_id: basic_product_info[:product_id])

                        unless product.nil?
                          next if product.stores.include? store
                        end
                      end

                      attribute_set = ::Gemgento::ProductAttributeSet.where(magento_id: basic_product_info[:set]).first
                      fetch(basic_product_info[:product_id], attribute_set, store)
                    end
                  end
                end
              end
            end
          end

          def self.associate_simple_products_to_configurable_products
            ::Gemgento::Product.skip_callback(:save, :after, :sync_local_to_magento)

            ::Gemgento::Product.where(magento_type: 'configurable').each do |configurable_product|
              configurable_product.simple_products.clear
              configurable_product.simple_products = MagentoDB.associated_simple_products(configurable_product)
            end

            ::Gemgento::Product.set_callback(:save, :after, :sync_local_to_magento)
          end

          def self.fetch(product_id, attribute_set, store)
            response = info(product_id, attribute_set, store)

            if response.success?
              product = sync_magento_to_local(response.body[:info], store)
              API::SOAP::Catalog::ProductAttributeMedia.fetch(product, store)
            end
          end

          # Get a list of products from Magento.
          #
          # @param store [Gemgento::Store]
          # @param last_updated [String] db formatted date string.
          # @return [Gemgento::MagentoResponse]
          def self.list(store = nil, last_updated = nil)
            store = Store.current if store.nil?

            if last_updated.nil?
              message = {}
            else
              message = {
                  store_view: store.magento_id,
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

            response = MagentoApi.create_call(:catalog_product_list, message)

            if response.success? && !response.body_overflow[:store_view].nil? && !response.body_overflow[:store_view].is_a?(Array)
              response.body_overflow[:store_view] = [response.body_overflow[:store_view]]
            end

            return response
          end

          # Get Product info from Magento.
          #
          # @param product_id [Integer] Magento product id.
          # @param attribute_set [Gemgento::ProductAttributeSet]
          # @param store [Gemgento::Store]
          # @return [Gemgento::MagentoResponse]
          def self.info(product_id, attribute_set, store)
            additional_attributes = []
            attribute_set.product_attributes.each do |attribute|
              next if %w[tier_price group_price].include? attribute.code
              additional_attributes << attribute.code
            end

            message = {
                product: product_id, # <= Magento 1.7.2
                product_id: product_id, # >= Magento 1.8.0 and higher
                productIdentifierType: 'id',
                attributes: {
                    'additional_attributes' => { 'item' => additional_attributes }
                },
                store_view: store.magento_id
            }
            MagentoApi.create_call(:catalog_product_info, message)
          end

          # Create a new Product in Magento.
          #
          # @param product [Gemgento::Product]
          # @param store [Gemgento::Store]
          # @return [Gemgento::MagentoResponse]
          def self.create(product, store)
            message = {
                type: product.magento_type,
                set: product.product_attribute_set.magento_id,
                sku: product.sku,
                product_data: compose_product_data(product, store),
                store_view: store.magento_id
            }
            MagentoApi.create_call(:catalog_product_create, message)
          end

          # Update existing Magento Product.
          #
          # @param product [Gemgento::Product]
          # @param store [Gemgento::Store]
          # @return [Gemgento::MagentoResponse]
          def self.update(product, store)
            message = {
                product: product.magento_id,
                product_identifier_type: 'id',
                product_data: compose_product_data(product, store),
                store_view: store.magento_id
            }
            MagentoApi.create_call(:catalog_product_update, message)
          end

          # Delete a product in Magento.
          #
          # @param product [Gemgento::Product]
          # @return [Gemgento::MagentoResponse]
          def self.delete(product)
            message = { product: product.magento_id, product_identifier_type: 'id' }
            MagentoApi.create_call(:catalog_product_delete, message)
          end

          def self.check_magento(identifier, identifier_type, attribute_set, store)
            additional_attributes = []
            attribute_set.product_attributes.each do |attribute|
              next if %w[tier_price group_price].include? attribute.code
              additional_attributes << attribute.code
            end

            message = {
                product: identifier,
                productIdentifierType: identifier_type,
                attributes: {
                    'additional_attributes' => {'arr:string' => additional_attributes}
                }
            }

            response = MagentoApi.create_call(:catalog_product_info, message)

            unless response.success?
              return ::Gemgento::Product.new
            else
              return sync_magento_to_local(response.body[:info], store)
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
            Product.not_deleted.where('magento_id NOT IN (?)', all_magento_product_ids).each do |product|
              product.mark_deleted!
            end
          end

          private

          def self.sync_magento_to_local(subject, store)
            Gemgento::Product.skip_callback(:save, :after, :touch_categories)
            Gemgento::Product.skip_callback(:save, :after, :touch_configurables)

            product = Gemgento::Product.where(magento_id: subject[:product_id]).not_deleted.first_or_initialize
            product.magento_id = subject[:product_id]
            product.magento_type = subject[:type]
            product.sku = subject[:sku]
            product.sync_needed = false
            product.product_attribute_set = Gemgento::ProductAttributeSet.where(magento_id: subject[:set]).first
            product.stores << store unless product.stores.include? store
            product.save!

            product.set_attribute_value('name', subject[:name], store)
            product.set_attribute_value('description', subject[:description], store)
            product.set_attribute_value('short_description', subject[:short_description], store)
            product.set_attribute_value('weight', subject[:weight], store)
            product.set_attribute_value('url_key', subject[:url_key], store)
            product.set_attribute_value('url_path', subject[:url_path], store)
            product.set_attribute_value('has_options', subject[:has_options], store)
            product.set_attribute_value('gift_message_available', subject[:gift_message_available], store)
            product.set_attribute_value('price', subject[:price], store)
            product.set_attribute_value('special_price', subject[:special_price], store)
            product.set_attribute_value('special_from_date', subject[:special_from_date], store)
            product.set_attribute_value('special_to_date', subject[:special_to_date], store)
            product.set_attribute_value('tax_class_id', subject[:tax_class_id], store)
            product.set_attribute_value('meta_title', subject[:meta_title], store)
            product.set_attribute_value('meta_keyword', subject[:meta_keyword], store)
            product.set_attribute_value('meta_description', subject[:meta_description], store)
            product.set_attribute_value('custom_design', subject[:custom_design], store)
            product.set_attribute_value('custom_layout_update', subject[:custom_layout_update], store)
            product.set_attribute_value('options_container', subject[:options_container], store)
            product.set_attribute_value('enable_googlecheckout', subject[:enable_googlecheckout], store)

            set_categories(subject[:categories][:item], product, store) if subject[:categories][:item]
            set_attribute_values_from_magento(subject[:additional_attributes][:item], product, store) if (subject[:additional_attributes] and subject[:additional_attributes][:item])
            set_associated_products(subject[:simple_product_ids], subject[:configurable_product_ids], product)
            set_bundle_options(subject[:bundle_options][:item], product) if subject[:bundle_options] && subject[:bundle_options][:item]
            set_tier_prices(subject[:tier_price][:item], product, store) if subject[:tier_price] && subject[:tier_price][:item]

            Gemgento::Product.set_callback(:save, :after, :touch_categories)
            Gemgento::Product.set_callback(:save, :after, :touch_configurables)

            return product
          end

          def self.set_categories(magento_categories, product, store)
            product_category_ids = []

            # if there is only one category, the returned value is not interpreted array
            magento_categories = [magento_categories] unless magento_categories.is_a? Array

            # loop through each return category and add it to the product if needed
            magento_categories.each do |magento_category|
              category = ::Gemgento::Category.find_by(magento_id: magento_category)
              next if category.nil?

              product_category = ProductCategory.unscoped.find_or_initialize_by(category: category, product: product, store: store)
              product_category.save

              product_category_ids << product_category.id
            end

            ProductCategory.unscoped.
                where('store_id = ? AND product_id = ? AND id NOT IN (?)', store.id, product.id, product_category_ids).
                destroy_all
          end

          def self.set_attribute_values_from_magento(magento_attribute_values, product, store)
            magento_attribute_values.each do |attribute_value|

              if attribute_value[:key] == 'visibility'
                product.visibility = attribute_value[:value].to_i
                product.save
              elsif attribute_value[:key] == 'status'
                product.status = attribute_value[:value].to_i == 1 ? 1 : 0
                product.save
              else
                product.set_attribute_value(attribute_value[:key], attribute_value[:value], store)
              end

            end
          end

          def self.compose_product_data(product, store)
            product_data = {
                'name' => product.name,
                'description' => product.description,
                'short_description' => product.short_description,
                'weight' => product.weight,
                'status' => product.status ? 1 : 2,
                'categories' => { 'item' => compose_categories(product) },
                'websites' => { 'item' => compose_websites(product) },
                'url_key' => product.attribute_value('url_key'),
                'price' => product.attribute_value('price'),
                'tax_class_id' => '2',
                'additional_attributes' => {'single_data' => {'item' => compose_attribute_values(product, store)}},
                'visibility' => product.visibility
            }

            unless product.simple_products.empty?
              product_data.merge!({
                                      'associated_skus' => {item: compose_associated_skus(product)},
                                      'price_changes' => compose_price_changes(product, store),
                                      'configurable_attributes' => {item: compose_configurable_attributes(product)}
                                  })
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

          def self.compose_websites(product)
            websites = []

            product.stores.each do |store|
              websites << "#{store.website_id}"
            end

            websites
          end

          def self.compose_configurable_attributes(product)
            configurable_attributes = []

            product.configurable_attributes.each do |configurable_attribute|
              configurable_attributes << "#{configurable_attribute.magento_id}"
            end

            configurable_attributes
          end

          def self.compose_attribute_values(product, store)
            attributes = []

            product.product_attribute_values.where(store: store).each do |product_attribute_value|
              if !product_attribute_value.value.nil? && !product_attribute_value.product_attribute.nil?
                attributes << {
                    key: product_attribute_value.product_attribute.code,
                    value: product.attribute_value(product_attribute_value.product_attribute.code, store)
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

          def self.compose_price_changes(product, store)
            price_changes = []

            product.configurable_attributes.each do |configurable_attribute|
              options = []

              configurable_attribute.product_attribute_options.where(store: store).each do |attribute_option|
                options << { key: attribute_option.label, value: '' }
              end

              price_changes << { key: configurable_attribute.code, value: options }
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

          def self.set_associated_products(simple_magento_product_ids, configurable_magento_product_ids, product)
            if !simple_magento_product_ids.nil? && !simple_magento_product_ids[:item].nil?
              ids = MagentoApi.enforce_savon_array(simple_magento_product_ids[:item])
              product.set_simple_products_by_magento_ids(ids)
            end

            if !configurable_magento_product_ids.nil? && !configurable_magento_product_ids[:item].nil?
              ids = MagentoApi.enforce_savon_array(configurable_magento_product_ids[:item])
              product.set_configurable_products_by_magento_ids(ids)
            end
          end

          def self.set_bundle_options(bundle_options_data, product)
            bundle_options_data.each do |bundle_option_data|
              bundle_option = product.bundle_options.find_or_initialize_by(magento_id: bundle_option_data[:id])
              bundle_option.is_required = bundle_option_data[:required].to_i == 1 ? true : false
              bundle_option.position = bundle_option_data[:position]
              bundle_option.name = bundle_option_data[:default_title]

              bundle_option_data[:type] = 'selection' if bundle_option_data[:type] == 'select'
              bundle_option.input_type = Gemgento::Bundle::Option.input_types[bundle_option_data[:type].to_sym]

              bundle_option.save

              if bundle_option_data[:selections] && bundle_option_data[:selections][:item]
                bundle_option_data[:selections][:item].each do |selection|
                  bundle_item = bundle_option.items.find_or_initialize_by(magento_id: selection[:id])
                  bundle_item.product = Gemgento::Product.find_by(magento_id: selection[:product_id])
                  bundle_item.price_type = selection[:price_type].to_i
                  bundle_item.price_value = selection[:price_value].to_f
                  bundle_item.default_quantity = selection[:qty].to_f
                  bundle_item.is_user_defined_quantity = selection[:can_change_qty].to_i == 1
                  bundle_item.position = selection[:position]
                  bundle_item.is_default = selection[:is_default].to_i == 1
                  bundle_item.save
                end
              end
            end
          end

          def self.set_tier_prices(tier_prices, product, store)
            tier_prices = [tier_prices] unless tier_prices.is_a?(Array)
            prices = []

            tier_prices.each do |source|

              if source[:all_groups]
                user_group = nil
              else
                user_group = Gemgento::UserGroup.find_by(magento_id: source[:cust_group])
              end

              price = product.price_tiers.find_or_create_by(
                  user_group: user_group,
                  store: store,
                  quantity: source[:price_qty],
                  price: source[:website_price]
              )

              prices << price
            end

            # remove unused product price tiers for the store
            product.price_tiers.where(store: store).where.not(id: prices.map(&:id)).destroy_all
          end

        end
      end
    end
  end
end
