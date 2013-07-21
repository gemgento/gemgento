module Gemgento
  class Users::AddressesController < BaseController
    layout 'application'

    def index
      @new_shipping_address = Address.new
      @default_shipping_address = current_user.addresses.find_by(address_type: 'shipping', is_default: true)
      @shipping_addresses = current_user.addresses.where(address_type: 'shipping', is_default: false)

      @new_billing_address = Address.new
      @default_billing_address = current_user.addresses.find_by(address_type: 'billing', is_default: true)
      @billing_addresses = current_user.addresses.where(address_type: 'billing', is_default: false)
    end

    def show

    end

    def create
      @address = Address.new(address_params)
      @address.user = current_user

      respond_to do |format|
        if @address.save
          format.html { redirect_to '/users/addresses', notice:'The new address was created successfully.' }
          format.js { render '/gemgento/users/addresses/success' }
        else
          format.html { redirect_to '/users/addresses', error: @address.errors.empty? ? 'Error' : @address.errors.full_messages.to_sentence }
          format.js { render '/gemgento/users/addresses/errors' }
        end
      end
    end

    def update
      @address = Address.find(params[:id])

      respond_to do |format|
        if @address.update_attributes(address_params)
          format.html { redirect_to '/users/addresses', notice:'The new address was created successfully.' }
          format.js { render '/gemgento/users/addresses/success' }
        else
          format.html { redirect_to '/users/addresses', error: @address.errors.empty? ? 'Error' : @address.errors.full_messages.to_sentence }
          format.js { render '/gemgento/users/addresses/errors' }
        end
      end
    end

    private

    def address_params
      params.require(:address).permit(:fname, :lname, :country, :city, :region, :postcode, :telephone)
    end
  end
end