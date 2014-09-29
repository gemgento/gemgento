module Gemgento
  module API
    module SOAP
      class AuthorizeNetCim

        def self.payment_profiles(customer_id)
          response = Gemgento::Magento.create_call(:customer_customer_authnet_cim_cards, { customer_id: customer_id })

          if response.success?
            return response.body
          else
            return response.body[:faultstring]
          end
        end
      end
    end
  end
end