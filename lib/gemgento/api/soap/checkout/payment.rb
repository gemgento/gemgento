module Gemgento
  module API
    module SOAP
      module Checkout
        class Payment

          def self.list(cart)
            message = {
                quote_id: cart.magento_quote_id,
                store_id: cart.store.magento_id
            }
            Magento.create_call(:shopping_cart_payment_list, message)
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
                    'cc_exp_month' => payment.cc_exp_month,
                    'additional_information' => compose_additional_information(payment)
                },
                store_id: cart.store.magento_id
            }
            Magento.create_call(:shopping_cart_payment_method, message)
          end

          def self.compose_additional_information(payment)
            additional_information = []
            additional_information << { key: 'save_card', value: payment.save_card } unless payment.save_card.nil?
            additional_information << { key: 'payment_id', value: payment.payment_id } unless payment.payment_id.nil?

            return { item: additional_information }
          end

        end
      end
    end
  end
end