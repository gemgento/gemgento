module Gemgento
  class Magento::AddressAdapter

    attr_accessor :source, :addressable

    def initialize(source, addressable)
      @source = source
      @addressable = addressable
    end

    def import
      address = Gemgento::Address.find_or_initialize_by(addressable: addressable)
      address.increment_id = self.source[:increment_id]
      address.city = self.source[:city]
      address.company = self.source[:company]
      address.country = Gemgento::Country.find_by(magento_id: self.source[:country_id])
      address.fax = self.source[:fax]
      address.first_name = self.source[:firstname]
      address.middle_name = self.source[:middlename]
      address.last_name = self.source[:lastname]
      address.postcode = self.source[:postcode]
      address.prefix = self.source[:prefix]
      address.region_name = self.source[:region]
      address.region = Gemgento::Region.find_by(magento_id: self.source[:region_id])
      address.street = self.source[:street]
      address.suffix = self.source[:suffix]
      address.telephone = self.source[:telephone]
      address.is_billing = (self.source[:address_type] == 'billing')
      address.is_shipping = (self.source[:address_type] == 'shipping')
      address.sync_needed = false
      address.save! validate: false

      return address
    end

  end
end