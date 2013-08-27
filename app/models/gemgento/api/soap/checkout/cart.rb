module Gemgento
  module API
    module SOAP
      module Checkout
        class Cart

          def self.create(cart)
            message = {
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_create, message)

            if response.success?
              cart.magento_quote_id = response.body[:quote_id]
              cart.save
              return true
            else
              return false
            end
          end

          def self.order(cart)
            response = Gemgento::Magento.create_call(:shopping_cart_order, {quote_id: cart.magento_quote_id})

            if response.success?
              cart.increment_id = response.body[:result]
              cart.save
              Gemgento::API::SOAP::Sales::Order.fetch(cart.increment_id) #grab all the new order information
              return true
            else
              return false
            end
          end

          def self.info(cart)
            message = {
                quote_id: cart.magento_quote_id,
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_info, message)

            if response.success?
              return response.body[:result]
            else
              return false
            end
          end

          def self.totals(cart)
            message = {
                quote_id: cart.magento_quote_id,
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_totals, message)

            if response.success?
              response.body[:result][:item]
            end
          end

          def self.license(cart)
            message = {
                quote_id: cart.magento_quote_id,
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_license, message)

            if response.success?
              response.body[:result][:item]
            end
          end

        end
      end
    end
  end
end