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
                products: {item: compose_products_data(line_items)},
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
                products: {item: compose_products_data(line_items)},
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
                  'bundle_option' => nil,
                  'bundle_option_qty' => nil,
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

        end
      end
    end
  end
end