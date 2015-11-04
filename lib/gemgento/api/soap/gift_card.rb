module Gemgento
  module API
    module SOAP
      class GiftCard

        def self.check(code)
          MagentoApi.create_call(:giftcard_check, code: code)
        end

        def self.history(code)
          MagentoApi.create_call(:giftcard_history, code: code)
        end

        def self.create(data)
          MagentoApi.create_call(:giftcard_create, data: data)
        end

        def self.update(code, data)
          MagentoApi.create_call(:giftcard_update, code: code, data: data)
        end

        def self.quote_add(quote_id, code, store_id)
          message = { quote_id: quote_id, code: code, store_id: store_id }
          MagentoApi.create_call(:giftcard_quote_add, message)
        end

        def self.quote_remove(quote_id, code, store_id)
          message = { quote_id: quote_id, code: code }
          MagentoApi.create_call(:giftcard_quote_remove, message)
        end

      end
    end
  end
end