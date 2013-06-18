module Gemgento
  module API
    module SOAP
      module Checkout
        class Shipping

          def self.list(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_shipping_list, { quote_id: cart.magento_quote_id })
            response[:result][:item]
          end

          def self.method(cart, shipping_method)
            Gemgento::Magento.create_call(:shopping_cart_shipping_method, { quote_id: self.magento_quote_id, shipping_method: shipping_method })
          end

        end
      end
    end
  end
end