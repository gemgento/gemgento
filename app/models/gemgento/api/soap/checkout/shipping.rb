module Gemgento
  module API
    module SOAP
      module Checkout
        class Shipping

          def self.list(cart)
            message = {
                quote_id: cart.magento_quote_id,
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_shipping_list, message)

            if response.success?
              response.body[:result][:item] = [response.body[:result][:item]] unless response.body[:result][:item].is_a? Array

              return response.body[:result][:item]
            end
          end

          def self.method(cart, shipping_method)
            message = {
                quote_id: cart.magento_quote_id,
                method: shipping_method,
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_shipping_method, message)

            return response.success?
          end

        end
      end
    end
  end
end