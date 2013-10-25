module Gemgento
  module API
    module SOAP
      module Checkout
        class Payment

          def self.list(cart)
            message = {
                quote_id: cart.magento_quote_id,
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_payment_list, message)

            if response.success?
              return response.body[:result]
            end
          end

          def self.method(cart, payment)
            message = {
                quote_id: cart.magento_quote_id,
                method: {
                    'po_number' => payment.po_number,
                    method: payment.method,
                    'cc_cid' => payment.cc_cid,
                    'cc_owner' => payment.cc_owner,
                    'cc_number' => payment.cc_number,
                    'cc_type' => payment.cc_type,
                    'cc_exp_year' => payment.cc_exp_year,
                    'cc_exp_month' => payment.cc_exp_month
                },
                store_id: Gemgento::Store.current.magento_id
            }
            response = Gemgento::Magento.create_call(:shopping_cart_payment_method, message)

            return response.success
          end

        end
      end
    end
  end
end