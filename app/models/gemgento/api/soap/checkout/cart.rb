module Gemgento
  module API
    module SOAP
      module Checkout
        class Cart

          def self.create(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_create)

            if response.success?
              cart.magento_quote_id = response.body[:quote_id]
              cart.save
            end
          end

          def self.order(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_order, {quote_id: cart.magento_quote_id})

            if response.success?
              cart.increment_id = response.body[:result]
              cart.save
              response = Gemgento::API::SOAP::Sales::Order.fetch(cart.increment_id) #grab all the new order information
            end

            return response.success?
          end

          def self.info(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_info, {quote_id: cart.magento_quote_id})

            if response.result?
              response.body[:result]
            end
          end

          def self.totals(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_totals, {quote_id: cart.magento_quote_id})

            if response.success?
              response.body[:result][:item]
            end
          end

          def self.license(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_license, {quote_id: cart.magento_quote_id})

            if response.success?
              response.body[:result][:item]
            end
          end

        end
      end
    end
  end
end