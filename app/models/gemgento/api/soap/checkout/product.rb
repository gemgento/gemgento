module Gemgento
  module API
    module SOAP
      module Checkout
        class Product

          # Add items to Magento quote.
          #
          # @param [Gemgento::Order] cart
          # @param [Array(Gemgento::OrderItem)] order_items
          # @return [Gemgento::MagentoResponse]
          def self.add(cart, order_items)
            message = {
                quote_id: cart.magento_quote_id,
                products: { item: compose_products_data(order_items) },
                store_id: cart.store.magento_id
            }
            Gemgento::Magento.create_call(:shopping_cart_product_add, message)
          end

          # Update items in Magento quote.
          #
          # @param [Gemgento::Order] cart
          # @param [Array(Gemgento::OrderItem)] order_items
          # @return [Gemgento::MagentoResponse]
          def self.update(cart, order_items)
            message = {
                quote_id: cart.magento_quote_id,
                products: {item: compose_products_data(order_items)},
                store_id: cart.store.magento_id
            }
            Gemgento::Magento.create_call(:shopping_cart_product_update, message)
          end

          # Remove items from Magento quote.
          #
          # @param [Gemgento::Order] cart
          # @param [Array(Gemgento::OrderItem)] order_items
          # @return [Gemgento::MagentoResponse]
          def self.remove(cart, order_items)
            message = {
                quote_id: cart.magento_quote_id,
                products: {item: compose_products_data(order_items)},
                store_id: cart.store.magento_id
            }
            Gemgento::Magento.create_call(:shopping_cart_product_remove, message)
          end

          def self.list(cart)
            message = {
                quote_id: cart.magento_quote_id,
                store_id: cart.store.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_product_list, message)

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

          private

          def self.compose_products_data(order_items)
            products_data = []

            order_items.each do |order_item|
              qty = order_item.qty_ordered
              qty = qty.to_i if qty.to_i == qty # use an integer to avoid issue with decimals and 1 remaining item

              products_data << {
                  'product_id' => order_item.product.magento_id,
                  sku: order_item.product.sku,
                  qty: qty,
                  options: { item: (compose_options_data(order_item.options) unless order_item.options.nil?) },
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