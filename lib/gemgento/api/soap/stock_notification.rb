module Gemgento
  module API
    module SOAP
      class StockNotification

        def self.add(product_id, product_name, product_url, name, email, phone)
          message = {
              product_id: product_id,
              product_name: product_name,
              product_url: product_url,
              name: name,
              email: email,
              phone: phone
          }
          response = Magento.create_call(:stocknotification_add, message)

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