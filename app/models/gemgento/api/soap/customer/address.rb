module Gemgento
  module API
    module SOAP
      module Customer
        class Address

          def self.fetch_all
            Gemgento::User.find(:all).each do |user|
              list(user.magento_id).each do |address|
                  sync_magento_to_local(address, user)
              end
            end
          end

          def self.list(customer_id)
            response = Gemgento::Magento.create_call(:customer_address_list, { customer_id: customer_id })

            unless response[:result][:item].nil?
              unless response[:result][:item].is_a? Array
                response[:result][:item] = [response[:result][:item]]
              end
            else
              response[:result][:item] = []
            end

            response[:result][:item]
          end

          def self.info(address_id)
            response = Gemgento::Magento.create_call(:customer_address_list, { address_id: address_id })
            response[:result][:info]
          end

          def self.create(address)
            message = {
                customer_id: address.user.magento_id,
                address_data: compose_address_data(address)
            }
            response = Gemgento::Magento.create_call(:customer_address_create, message)

            address.user_address_id = response[:result]
            address.sync_needed = false
            address.save
          end

          def self.update(address)
            message = {
                address_id: address.user_address_id,
                address_data: compose_address_data(address)
            }
            Gemgento::Magento.create_call(:customer_address_update, message)
          end

          def self.delete(address_id)
            Gemgento::Magento.create_call(:customer_address_update, { address_id: address_id })
          end

          private

          # Save Magento users address to local
          def self.sync_magento_to_local(source, user)
            address = Gemgento::Address.find_or_initialize_by(user_address_id: source[:customer_address_id])
            address.user_address_id = source[:customer_address_id]
            address.user = user
            address.increment_id = source[:increment_id]
            address.city = source[:city]
            address.company = source[:company]
            address.country = Country.find_by(magento_id: source[:country_id])
            address.fax = source[:fax]
            address.fname = source[:firstname]
            address.mname = source[:middlename]
            address.lname = source[:lastname]
            address.postcode = source[:postcode]
            address.prefix = source[:prefix]
            address.region_name = source[:region]
            address.region = Region.find_by(magento_id: source[:region_id])
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
              firstname: address.fname,
              lastname: address.lname,
              middlename: address.mname,
              postcode: address.postcode,
              prefix: address.prefix,
              region: address.region_name,
              'region_id' => address.region.magento_id,
              street: { 'arr:string' => [address.street] },
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