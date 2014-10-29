module Gemgento
  module API
    module SOAP
      module Checkout
        class Shipping

          # Retrieve a list of shipping methods for a Quote from Magento.
          #
          # @param quote [Gemgento::Quote]
          # @return [Gemgento::MagentoResponse]
          def self.list(quote)
            message = {
                quote_id: quote.magento_id,
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_shipping_list, message)
          end

          # Set the Quote shipping method in Magento.
          #
          # @param quote [Gemgento::Quote]
          # @param shipping_method [String]
          # @return [Gemgento::MagentoResponse]
          def self.method(quote, shipping_method)
            message = {
                quote_id: quote.magento_id,
                method: shipping_method,
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_shipping_method, message)
          end

        end
      end
    end
  end
end