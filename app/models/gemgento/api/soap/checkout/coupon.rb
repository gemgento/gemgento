module Gemgento
  module API
    module SOAP
      module Checkout
        class Coupon

          def self.add(cart, coupon_code)
            message = {
                quote_id: cart.magento_quote_id,
                coupon_code: coupon_code
            }
            Gemgento::Magento.create_call(:shopping_cart_coupon_add, message)
          end

          def self.remove(cart)
            Gemgento::Magento.create_call(:shopping_cart_coupon_remove, { quote_id: cart.magento_quote_id })
          end

        end
      end
    end
  end
end