module Gemgento
  module API
    module SOAP
      module Authnetcim
        class Payment

          def self.list(customer_id)
            Magento.create_call(:authnetcim_payment_list, { customer_id: customer_id })
          end

        end
      end
    end
  end
end