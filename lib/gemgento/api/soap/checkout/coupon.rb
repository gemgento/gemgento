module Gemgento
  module API
    module SOAP
      module Checkout
        class Coupon

          # Add Coupon code to a Magento Quote.
          #
          # @param quote [Gemgento::Quote]
          # @param coupon_code [String]
          # @return [Gemgento::MagentoResponse]
          def self.add(quote, coupon_code)
            message = {
                quote_id: quote.magento_id,
                coupon_code: coupon_code,
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_coupon_add, message)
          end

          # Remove coupon codes from a Magento Quote.
          #
          # @param quote [Gemgento::Quote]
          # @return [Gemgento::MagentoResponse]
          def self.remove(quote)
            message = {
                quote_id: quote.magento_id,
                store_id: quote.store.magento_id
            }
            Magento.create_call(:shopping_cart_coupon_remove, message)
          end

        end
      end
    end
  end
end