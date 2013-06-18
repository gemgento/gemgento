module Gemgento
  module API
    module SOAP
      module Checkout
        class Cart

          def self.create(cart)
            cart.magento_quote_id = Gemgento::Magento.create_call(:shopping_cart_create)
            cart.save
          end

          def self.order(cart)
            Gemgento::Magento.create_call(:shopping_cart_order, { quote_id: cart.magento_quote_id })
          end

          def self.info(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_info, { quote_id: cart.magento_quote_id })
            response[:result]
          end

          def self.totals(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_totals, { quote_id: cart.magento_quote_id })
            response[:result][:item]
          end

          def self.license(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_license, { quote_id: cart.magento_quote_id })
            response[:result][:item]
          end

        end
      end
    end
  end
end