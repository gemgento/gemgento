module Gemgento
  class OrderAddress < ActiveRecord::Base
    belongs_to :order
    belongs_ :region
    belongs_to :country

    def self.sync_magento_to_local(source)
      order_address = OrderAddress.find_or_initialize_by(magento_id: source[:address_id])
      order_address.magento_id = source[:address_id]
      #order_address.increment_id = source[:increment_id]
      #order_address.is_active = source[:is_active]
      order_address.address_type = source[:address_type]
      order_address.fname = source[:firstname]
      order_address.lname = source[:lastname]
      order_address.company_name = source[:company]
      order_address.street = source[:street]
      order_address.city = source[:city]
      order_address.region_name = source[:region]
      order_address.postcode = source[:postcode]
      order_address.country_id = Country.find_by(magento_id: source[:country_id])
      order_address.telephone = source[:telephone]
      order_address.fax = source[:fax]
      order_address.region = Region.find_by(magento_id: source[:increment_id])
      order_address.save

      order_address
    end
  end
end