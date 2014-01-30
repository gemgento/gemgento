module Gemgento
  module API
    module SOAP
      module Customer
        class Address

          def self.fetch_all
            Gemgento::User.all.each do |user|
              fetch(user)
            end
          end

          def self.fetch(user)
            list(user.magento_id).each do |address|
              sync_magento_to_local(address, user)
            end
          end

          def self.list(customer_id)
            response = Gemgento::Magento.create_call(:customer_address_list, {customer_id: customer_id})

            if response.success?
              unless response.body[:result][:item].nil?
                unless response.body[:result][:item].is_a? Array
                  response.body[:result][:item] = [response.body[:result][:item]]
                end
              else
                response.body[:result][:item] = []
              end

              return response.body[:result][:item]
            end
          end

          def self.info(address_id)
            response = Gemgento::Magento.create_call(:customer_address_list, {address_id: address_id})

            if response.success?
              return response.body[:result][:info]
            end
          end

          def self.create(address)
            message = {
                customer_id: address.user.magento_id,
                address_data: compose_address_data(address)
            }
            response = Gemgento::Magento.create_call(:customer_address_create, message)

            if response.success?
              address.user_address_id = response.body[:result]
              address.sync_needed = false
              address.save
            end
          end

          def self.update(address)
            message = {
                address_id: address.user_address_id,
                address_data: compose_address_data(address)
            }
            response = Gemgento::Magento.create_call(:customer_address_update, message)

            return response.success?
          end

          def self.delete(address_id)
            response = Gemgento::Magento.create_call(:customer_address_update, {address_id: address_id})

            return response.success?
          end

          private

          # Save Magento users address to local
          def self.sync_magento_to_local(source, user)
            address = Gemgento::Address.where(user_address_id: source[:customer_address_id]).first_or_initialize
            address.user_address_id = source[:customer_address_id]
            address.user = user
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
            address.region = Region.where(magento_id: source[:region_id]).first
            address.street = source[:street]
            address.suffix = source[:suffix]
            address.telephone = source[:telephone]
            address.is_default = (source[:is_default_billing] || source[:is_default_shipping]) ? true : false
            address.address_type = source[:is_default_billing] ? 'billing' : 'shipping'
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
                'region_id' => address.region.magento_id,
                street: {'arr:string' => [address.street]},
                suffix: address.suffix,
                telephone: address.telephone,
                'is_default_billing' => (address.address_type == 'billing' && address.is_default) ? true : false,
                'is_default_shipping' => (address.address_type == 'shipping' && address.is_default) ? true : false
            }

            address_data
          end

        end
      end
    end
  end
end