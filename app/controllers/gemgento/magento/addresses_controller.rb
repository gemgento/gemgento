module Gemgento
  class Magento::AddressesController < MagentoController

    def update
      data = params[:data]
      @user = User.find_by(magento_id: data[:customer_id])

      unless @user.nil?
        @address = Address.find_or_initialize_by(magento_id: data[:entity_id], addressable_type: 'Gemgento::User')
        @address.addressable = @user
        @address.city = data[:city]
        @address.company = data[:company]
        @address.country = Country.where(magento_id: data[:country_id]).first
        @address.fax = data[:fax]
        @address.first_name = data[:firstname]
        @address.middle_name = data[:middlename]
        @address.last_name = data[:lastname]
        @address.postcode = data[:postcode]
        @address.prefix = data[:prefix]
        @address.region_name = data[:region]
        @address.region = Region.where(magento_id: data[:region_id]).first
        @address.street = data[:street]
        @address.suffix = data[:suffix]
        @address.telephone = data[:telephone]
        @address.is_billing = data[:is_default_billing]
        @address.is_shipping = data[:is_default_shipping]
        @address.sync_needed = false
        @address.save
      end

      render nothing: true
    end

    def destroy
      Address.skip_callback(:destroy, :before, :destroy_magento)

      @address = Address.find_by(magento_id: params[:id], addressable_type: 'Gemgento::User')
      @address.destroy unless @address.nil?

      Address.set_callback(:destroy, :before, :destroy_magento)

      render nothing: true
    end

  end
end