module Gemgento
  module API
    module SOAP
      module Checkout
        class Product

          def self.add(cart, order_items)
            message = {
                quote_id: cart.magento_quote_id,
                products: {item: compose_products_data(order_items)},
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_product_add, message)

            if response.success?
              return response.body[:result]
            end
          end

          def self.update(cart, products)
            message = {
                quote_id: cart.magento_quote_id,
                products: {item: compose_products_data(products)},
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_product_update, message)

            if response.success?
              return response.body[:result]
            end
          end

          def self.remove(cart, products)
            message = {
                quote_id: cart.magento_quote_id,
                products: {item: compose_products_data(products)},
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_product_remove, message)

            if response.success?
              response.body[:result]
            end
          end

          def self.list(cart)
            message = {
                quote_id: cart.magento_quote_id,
                store_id: Gemgento::Store.current.magento_id
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