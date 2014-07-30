module Gemgento
  module API
    module SOAP
      module Sales
        class RecurringProfile

          # Fetch and sync all recurring profiles from Magento.
          #
          # @return [Boolean]
          def self.fetch_all
            if magento_profiles = list
              magento_profiles.each{ |source| sync_magento_to_local(source) }
              return true
            else
              return false
            end
          end

          # Get a list of all recurring profiles from Magento.
          #
          # @return [Array(Hash), Boolean]
          def self.list
            response = Gemgento::Magento.create_call(:sales_recurring_profile_list)

            if response.success?
              return response.body[:result][:item].is_a?(Array) ? response.body[:result][:item] : [response.body[:result][:item]]
            else
              return false
            end
          end

          # Update a recurring profile state in Magento.
          #
          # @param [Integer] profile_id
          # @param [String] state
          # @return [Boolean]
          def self.update_state(profile_id, state)
            message = {
                profile_id: profile_id,
                state: state
            }
            response = Gemgento::Magento.create_call(:sales_recurring_profile_update_state, message)

            return response.success?
          end
          
          private

          # Sync a Magento recurring profile to Gemgento.
          #
          # @param [Hash] source
          # @return [Gemgento::Profile]
          def self.sync_magento_to_local(source)
            profile = Gemgento::RecurringProfile.find_or_initialize_by(magento_id: source[:profile_id])
            profile.state = source[:state]
            profile.store = Gemgento::Store.find_by(magento_id: source[:store_id])
            profile.method_code = source[:method_code]
            profile.reference_id = source[:reference_id]
            profile.subscriber_name = source[:subscriber_name]
            profile.start_datetime = source[:start_datetime].to_datetime
            profile.internal_reference_id = source[:internal_reference_id]
            profile.schedule_description = source[:schedule_description]
            profile.period_unit = source[:period_unit]
            profile.period_frequency = source[:period_frequency]
            profile.billing_amount = source[:billing_amount]
            profile.currency_code = source[:currency_code]
            profile.shipping_amount = source[:shipping_amount]
            profile.tax_amount = source[:tax_amount]

            if user = Gemgento::User.find_by(magento_id: source[:customer_id])
              profile.user = user
            end

            profile.save
            profile.orders = Gemgento::Order.where(order_id: source[:order_ids][:item])

            return profile
          end

        end
      end
    end
  end
end
