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

          def self.create
            # TODO: Create create API call
          end

          def self.update
            # TODO: Create update API call
          end

          def self.delete
            # TODO: Create delete API call
          end

          private

          # Save Magento user address to local
          def self.sync_magento_to_local(source, user)
            address = Gemgento::Address.find_or_initialize_by(customer_address_id: source[:customer_address_id])
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
            address.is_default_billing = source[:is_default_billing]
            address.is_default_shipping = source[:is_default_shipping]
            address.address_type = source[:address_type]
            address.sync_needed = false
            address.save

            address
          end

        end
      end
    end
  end
end