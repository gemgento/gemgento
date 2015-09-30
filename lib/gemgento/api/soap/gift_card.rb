module Gemgento
  module API
    module SOAP
      class GiftCard

        def self.create(gift_code, balance, store_id)
          message = { gift_code: gift_code, 
                      pattern: gift_code, 
                      store_id: store_id, 
                      amount: balance,
                      balance: balance,
                      currency: 'USD',
                      status: 'enabled',
                      expired_at: '',
                      customer_id: Gemgento::User.last.magento_id,
                      customer_name: 'phil',
                      customer_email: 'phil@mauinewyork.com',
                      recipient_name: 'phil',
                      recipient_email: 'phil@mauinewyork.com',
                      recipient_address: '',
                      message: 'physical-gift-card',
                      store_id: "1",
                      conditions_serialized: '',
                      day_to_send: '',                                            
                      is_sent: '',
                      shipped_to_customer: '',
                      created_form: '',
                      template_id: '',
                      description: '',
                      giftvoucher_comments: ''
                    }
          
          response = MagentoApi.create_call(:giftcard_create, {data: message})
          # attempt to update gift card with correct code - with update call
          gc = response.body[:result][:gift_code]          
          MagentoApi.create_call(:giftcard_update, {data: message})
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