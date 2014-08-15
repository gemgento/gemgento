module Gemgento
  module API
    module SOAP
      class GiftCard

        def self.quote_add(quote_id, code, store_id)
          message = { quote_id: quote_id, code: code, store_id: store_id }
          response = Gemgento::Magento.create_call(:giftcard_quote_add, message)

          if response.success?
            return true
          else
            return response.body[:faultstring]
          end
        end

        def self.quote_remove(quote_id, code, store_id: store_id)
          message = { quote_id: quote_id, code: code }
          response = Gemgento::Magento.create_call(:giftcard_quote_remove, message)

          if response.success?
            return true
          else
            return response.body[:faultstring]
          end
        end

      end
    end
  end
end