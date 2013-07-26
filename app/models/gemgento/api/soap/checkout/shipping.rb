module Gemgento
  module API
    module SOAP
      module Checkout
        class Shipping

          def self.list(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_shipping_list, {quote_id: cart.magento_quote_id})

            if response.success?
              return response.body[:result][:item]
            end
          end

          def self.method(cart, shipping_method)
            response = Gemgento::Magento.create_call(:shopping_cart_shipping_method, {quote_id: cart.magento_quote_id, method: shipping_method})

            return response.success?
          end

        end
      end
    end
  end
end