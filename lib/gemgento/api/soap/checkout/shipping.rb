module Gemgento
  module API
    module SOAP
      module Checkout
        class Shipping

          def self.list(cart)
            message = {
                quote_id: cart.magento_quote_id,
                store_id: cart.store.magento_id
            }
            Magento.create_call(:shopping_cart_shipping_list, message)
          end

          def self.method(cart, shipping_method)
            message = {
                quote_id: cart.magento_quote_id,
                method: shipping_method,
                store_id: cart.store.magento_id
            }
            Magento.create_call(:shopping_cart_shipping_method, message)
          end

        end
      end
    end
  end
end