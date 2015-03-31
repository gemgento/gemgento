module Gemgento
  module API
    module SOAP
      module Customer
        class Address

          # Fetch Customer Addresses for all Gemgento Users from Magento.
          #
          # @return [Void]
          def self.fetch_all
            User.all.each do |user|
              fetch(user)
            end
          end

          # Fetch Customer Addresses for a User and sync them to Gemgento.
          #
          # @param user [Gemgento::User]
          # @return [Void]
          def self.fetch(user)
            response = list(user.magento_id)

            if response.success?
              response.body[:result][:item].each do |address|
                sync_magento_to_local(address, user)
              end
            end
          end

          # Get a list of all Magento Addresses for a specific customer.
          #
          # @param customer_id [Integer] Magento Customer id.
          # @return [Gemgento::MagentoResponse]
          def self.list(customer_id)
            response = MagentoApi.create_call(:customer_address_list, {customer_id: customer_id})

            if response.success?
              if response.body[:result][:item].nil?
                response.body[:result][:item] = []
              elsif !response.body[:result][:item].is_a? Array
                response.body[:result][:item] = [response.body[:result][:item]]
              end
            end

            return response
          end

          # Get Magento Address data.
          #
          # @param address_id [Integer] Magento Address id.
          # @return [Gemgento::MagentoReponse]
          def self.info(address_id)
            MagentoApi.create_call(:customer_address_list, { address_id: address_id })
            # response.body[:result][:info]
          end

          # Create a Customer Address in Magento.
          #
          # @param address [Gemgento::Address]
          # @return [Gemgento::MagentoResponse]
          def self.create(address)
            message = {
                customer_id: address.addressable.magento_id,
                address_data: compose_address_data(address)
            }
            MagentoApi.create_call(:customer_address_create, message)
          end

          # Update a Customer Address in Magento.
          #
          # @param address [Gemgento::Address]
          # @return [Gemgento::MagentoResponse]
          def self.update(address)
            message = {
                address_id: address.magento_id,
                address_data: compose_address_data(address)
            }
            MagentoApi.create_call(:customer_address_update, message)
          end

          # Delete a Customer Address in Magento.
          #
          # @return [Gemgento::MagentoResponse]
          def self.delete(address_id)
            MagentoApi.create_call(:customer_address_update, {address_id: address_id})
          end

          private

          # Save Magento users address to local
          def self.sync_magento_to_local(source, user)
            address = Gemgento::Address.find_or_initialize_by(magento_id: source[:customer_address_id], addressable: user)
            address.increment_id = source[:increment_id]
            address.city = source[:city]
            address.company = source[:company]
            address.country = Country.where(magento_id: source[:country_id]).first
            address.fax = source[:fax]
            address.first_name = source[:firstname]
            address.middle_name = source[:middlename]
            address.last_name = source[:lastname]
            address.postcode = source[:postcode]
            address.prefix = source[:prefix]
            address.region_name = source[:region]
            address.region = ::Gemgento::Region.where(magento_id: source[:region_id]).first
            address.street = source[:street]
            address.suffix = source[:suffix]
            address.telephone = source[:telephone]
            address.is_billing = source[:is_default_billing]
            address.is_shipping = source[:is_default_shipping]
            address.sync_needed = false
            address.save

            address
          end

          def self.compose_address_data(address)
            address_data = {
                city: address.city,
                company: address.company,
                'country_id' => address.country.magento_id,
                fax: address.fax,
                firstname: address.first_name,
                lastname: address.last_name,
                middlename: address.middle_name,
                postcode: address.postcode,
                prefix: address.prefix,
                region: address.region_name,
                'region_id' => address.region.nil? ? nil : address.region.magento_id,
                street: {'arr:string' => [address.street]},
                suffix: address.suffix,
                telephone: address.telephone,
                'is_default_billing' => address.is_billing,
                'is_default_shipping' => address.is_shipping
            }

            address_data
          end

        end
      end
    end
  end
end