module Gemgento
  class Address < ActiveRecord::Base
    belongs_to :user
    belongs_to :country
    belongs_to :region

    def self.index
      if Address.find(:all).size == 0
        fetch_all
      end

      Address.find(:all)
    end

    def self.fetch_all
      User.find(:all).each do |user|
        message = {
            customer_id: user.magento_id
        }
        response = Gemgento::Magento.create_call(:customer_address_list, message)

        unless response[:result][:item].nil?
          unless response[:result][:item].is_a? Array
            response[:result][:item] = [response[:result][:item]]
          end

          response[:result][:item].each do |address|
            sync_magento_to_local(address, user)
          end
        end
      end
    end

    private

    # Save Magento user address to local
    def self.sync_magento_to_local(source, user)
      address = Address.find_or_initialize_by(magento_id: source[:customer_address_id])
      address.magento_id = source[:customer_address_id]
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
      address.sync_needed = false
      address.save
    end
  end
end