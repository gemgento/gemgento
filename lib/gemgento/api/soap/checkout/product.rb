module Gemgento
  module API
    module SOAP
      module Checkout
        class Product

          # Add items to Magento quote.
          #
          # @param quote [Gemgento::Quote]
          # @param line_items [Array(Gemgento::LineItem)]
          # @return [Gemgento::MagentoResponse]
          def self.add(quote, line_items)
            message = {
                quote_id: quote.magento_id,
                products: { item: compose_products_data(line_items) },
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_product_add, message)
          end

          # Update items in Magento quote.
          #
          # @param quote [Gemgento::Quote]
          # @param line_items [Array(Gemgento::LineItem)]
          # @return [Gemgento::MagentoResponse]
          def self.update(quote, line_items)
            message = {
                quote_id: quote.magento_id,
                products: { item: compose_products_data(line_items) },
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_product_update, message)
          end

          # Remove items from Magento quote.
          #
          # @param quote [Gemgento::Quote]
          # @param line_items [Array(Gemgento::LineItem)]
          # @return [Gemgento::MagentoResponse]
          def self.remove(quote, line_items)
            message = {
                quote_id: quote.magento_id,
                products: { item: compose_products_data(line_items) },
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_product_remove, message)
          end

          # List all items in a quote
          #
          # @param quote [Gemgento::Quote]
          # @return [Gemgento::MagentoResponse]
          def self.list(quote)
            message = {
                quote_id: quote.magento_id,
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_product_list, message)
          end

          private

          # An array with the list of shoppingCartProductEntity
          #
          # @param line_items [Array(Gemgento::LineItem)]
          # @return [Array(Hash)]
          def self.compose_products_data(line_items)
            products_data = []

            line_items.each do |line_item|
              qty = line_item.qty_ordered
              qty = qty.to_i if qty.to_i == qty # use an integer to avoid issue with decimals and 1 remaining item

              products_data << {
                  'product_id' => line_item.product.magento_id,
                  sku: line_item.product.sku,
                  qty: qty,
                  options: { item: (compose_options_data(line_item.options) unless line_item.options.nil?) },
                  'bundle_option' => line_item.bundle_options.any? ? { item: bundle_option(line_item) } : nil,
                  'bundle_option_qty' => line_item.bundle_options.any? ? { item: bundle_option_qty(line_item) } : nil,
                  links: nil
              }
            end

            return products_data
          end

          def self.compose_options_data(options)
            options_data = []

            if options.any?
              options.each do |key, value|
                options_data << { key: key, value: value }
              end
            end

            return options_data
          end

          # Create array of bundle item options.
          #
          # @param line_item [Gemgento::LineItem]
          # @return [Hash]
          def self.bundle_option(line_item)
            bundle_options = []

            line_item.bundle_options.each do |line_item_option|
              bundle_options << {
                  key: line_item_option.bundle_item.option.magento_id,
                  value: line_item_option.bundle_item.magento_id
              }
            end

            return bundle_options
          end

          # Create array of bundle items quantity .
          #
          # @param line_item [Gemgento::LineItem]
          # @return [Array]
          def self.bundle_option_qty(line_item)
            bundle_option_qty = []

            line_item.bundle_options.each do |line_item_option|
              bundle_option_qty << {
                  key: line_item_option.bundle_item.option.magento_id,
                  value: line_item_option.quantity
              }
            end

            return bundle_option_qty
          end

        end
      end
    end
  end
end