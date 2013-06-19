module Gemgento
  module API
    module SOAP
      module Checkout
        class Product

          def self.add(cart, order_items)
            message = {
                quote_id: cart.magento_quote_id,
                products: { item: compose_products_data(order_items) }
            }
            response = Gemgento::Magento.create_call(:shopping_cart_product_add, message)
            response[:result]
          end

          def self.update(cart, products)
            message = {
                quote_id: cart.magento_quote_id,
                products: { item: compose_products_data(products) }
            }
            response = Gemgento::Magento.create_call(:shopping_cart_product_update, message)
            response[:result]
          end

          def self.remove(cart, products)
            message = {
                quote_id: cart.magento_quote_id,
                products: { item: compose_products_data(products) }
            }
            response = Gemgento::Magento.create_call(:shopping_cart_product_remove, message)
            response[:result]
          end

          def self.list(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_product_list, { quote_id: cart.magento_quote_id })

            if response[:result][:item].nil?
              response[:result][:item] = []
            end

            unless response[:result][:item].is_a? Array
              response[:result][:item] = [response[:result][:item]]
            end

            response[:result][:item]
          end

          private

          def self.compose_products_data(order_items)
            products_data = []

            order_items.each do |order_item|
              products_data << {
                'product_id' => order_item.product.magento_id,
                sku: order_item.product.sku,
                qty: order_item.qty_ordered,
                options: nil,
                'bundle_option' => nil,
                'bundle_option_qty' => nil,
                links: nil
              }
            end

            products_data
          end

        end
      end
    end
  end
end