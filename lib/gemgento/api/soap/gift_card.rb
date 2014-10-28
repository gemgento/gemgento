module Gemgento
  module API
    module SOAP
      class GiftCard

        def self.quote_add(quote_id, code, store_id)
          message = { quote_id: quote_id, code: code, store_id: store_id }
          Magento.create_call(:giftcard_quote_add, message)
        end

        def self.quote_remove(quote_id, code, store_id)
          message = { quote_id: quote_id, code: code }
          Magento.create_call(:giftcard_quote_remove, message)
        end

      end
    end
  end
end