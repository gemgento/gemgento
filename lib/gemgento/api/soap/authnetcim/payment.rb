module Gemgento
  module API
    module SOAP
      module Authnetcim
        class Payment

          # Get a list of saved payment methods for customer.
          #
          # @param customer_id [Integer] Magento customer id.
          # @return [Gemgento::MagentoResponse]
          def self.list(customer_id)
            Magento.create_call(:authnetcim_payment_list, { customer_id: customer_id })
          end

          # Create a new saved payment method for a customer
          #
          # @param customer_id [Integer] Magento customer id.
          # @param payment [Hash] Payment parameters
          # @return [Gemgento::MagentoResponse]
          def self.create(customer_id, payment)
            message = {
                customer_id: customer_id,
                payment: payment
            }
            Magento.create_call(:authnetcim_payment_create, message)
          end

          # Destroy a saved payment method for a customer.
          #
          # @param customer_id [Integer] Magento customer id.
          # @param payment_profile_id [String]
          # @return [Gemgento::MagentoResponse]
          def self.destroy(customer_id, payment_profile_id)
            message = {
                customer_id: customer_id,
                payment_profile_id: payment_profile_id
            }
            Magento.create_call(:authnetcim_payment_destroy, message)
          end

        end
      end
    end
  end
end