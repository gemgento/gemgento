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
            response = Magento.create_call(:authnetcim_payment_list, { customer_id: customer_id })

            # filter and enforce the array of cards on success
            if response.success?
              if response.body[:response].nil?
                response.body[:response] = {item: []}
              elsif response.body[:response][:item].nil?
                response.body[:response][:item] = []
              elsif !response.body[:response][:item].is_a? Array
                response.body[:response][:item] = [response.body[:response][:item]]
              end
            end

            return response
          end

          # Create a new saved payment method for a customer
          #
          # @param saved_credit_card [Gemgento::SavedCreditCard]
          # @return [Gemgento::MagentoResponse]
          def self.create(saved_credit_card)
            message = {
                customer_id: saved_credit_card.user.magento_id,
                payment: {
                    firstname: saved_credit_card.address.first_name,
                    lastname: saved_credit_card.address.last_name,
                    address1: saved_credit_card.address.street,
                    city: saved_credit_card.address.city,
                    state: saved_credit_card.address.region.magento_id,
                    zip: saved_credit_card.address.postcode,
                    country: saved_credit_card.address.country.iso2_code,
                    'cc_type' => saved_credit_card.cc_type,
                    'cc_number' => saved_credit_card.cc_number,
                    'cc_exp_month' => saved_credit_card.exp_month,
                    'cc_exp_year' => saved_credit_card.exp_year
                }
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

          # Fetch and sync all user saved credit cards.
          #
          # @param user [Gemgento::User]
          # @return [Void]
          def self.fetch(user)
            saved_cards = []
            response = list(user.magento_id)

            if response.success?
              response.body[:response][:item].each do |saved_card|
                saved_cards << sync_magento_to_local(user, saved_card)
              end
            end

            SavedCreditCard.skip_callback(:destroy, :before, :magento_destroy)
            user.saved_credit_cards.reload
            user.saved_credit_cards.where.not(id: saved_cards.map(&:id)).destroy_all
            SavedCreditCard.set_callback(:destroy, :before, :magento_destroy)
          end

          private

          # Sync a Magento saved credit card with a local one.
          #
          # @param user [Gemgento::User]
          # @param saved_card_params [Hash]
          # @return [Gemgento::SavedCreditCard]
          def self.sync_magento_to_local(user, saved_card_params)
            SavedCreditCard.skip_callback(:create, :before, :magento_create)
            saved_credit_card = SavedCreditCard.find_or_initialize_by(
                user: user,
                token: saved_card_params[:customer_payment_profile_id]
            )
            saved_credit_card.cc_number = saved_card_params[:payment][:credit_card][:card_number]
            saved_credit_card
            saved_credit_card.save
            SavedCreditCard.set_callback(:create, :before, :magento_create)

            # address / bill_to data
            address = ::Gemgento::Address.find_or_initialize_by(addressable: saved_credit_card)
            address.first_name = saved_card_params[:bill_to][:first_name]
            address.last_name = saved_card_params[:bill_to][:last_name]
            address.street = saved_card_params[:bill_to][:address]
            address.city = saved_card_params[:bill_to][:city]
            address.country = ::Gemgento::Country.find_by(iso2_code: saved_card_params[:bill_to][:country])
            address.postcode = saved_card_params[:bill_to][:zip]

            if address.country.regions.any?
              address.region = address.country.regions.find_by(name: saved_card_params[:bill_to][:state])
            end

            address.save validate: false

            return saved_credit_card
          end


        end
      end
    end
  end
end
