module Gemgento
  module API
    module SOAP
      module Checkout
        class Payment

          # Get a list of payment methods available for a Quote from Magento.
          #
          # @param quote [Gemgento::Quote]
          # @return [Gemgento::MagentoResponse]
          def self.list(quote)
            message = {
                quote_id: quote.magento_id,
                store_id: quote.store.magento_id
            }
            MagentoApi.create_call(:shopping_cart_payment_list, message)
          end

          # Set the payment method for a Quote in Magento.
          #
          # @param quote [Gemgento::Quote]
          # @param payment [Gemgento::Payment]
          # @return [Gemgento::MagentoResponse]
          def self.method(quote, payment)
            message = {
                quote_id: quote.magento_id,
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
                store_id: quote.store.magento_id
            }
            MagentoApi.create_call(:shopping_cart_payment_method, message)
          end

          # Compose additional payment attributes hash for Magento API call.
          #
          # @param payment [Gemgento::Payment]
          # @return [Hash]
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