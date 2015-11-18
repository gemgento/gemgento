module Gemgento
  class User::AddressesController < User::BaseController

    def index
      @addresses = current_user.addresses
      respond_with @addresses
    end

    def show
      @address = current_user.address_book.find(params[:id])
      respond_with @address
    end

    def new
      @address = Gemgento::Address.new
    end

    def edit
      @address = current_user.addresses.find(params[:id])
      respond_with @address
    end

    def create
      @address = Gemgento::Address.new(address_params)
      @address.addressable = current_user
      @address.sync_needed = true

      respond_to do |format|

        if @address.save
          format.html { redirect_to user_addresses_path, notice: 'The address has been added successfully.' }
          format.json { render json: { result: true, address: @address } }
        else
          format.html { render 'new' }
          format.json { render json: { result: false, errors: @address.errors.full_messages } }
        end

      end
    end

    def update
      @address = current_user.addresses.find(params[:id])
      @address.sync_needed = true

      respond_to do |format|
        if @address.update_attributes(address_params)
          format.html { redirect_to user_addresses_path, notice: 'The address has been updated successfully.' }
          format.json { render json: { result: true, address: @address } }
        else
          format.html { render 'edit' }
          format.json { render json: { result: false, errors: @address.errors.full_messages } }
        end
      end
    end

    def destroy
      @address = current_user.addresses.find(params[:id])

      respond_to do |format|
        if @address.destroy
          format.html { redirect_to user_addresses_path, notice: 'The address has been deleted from your address book.' }
          format.json { render json: { result: true } }
        else
          format.html { redirect_to user_addresses_path, alert: 'The address could not be destroyed.' }
          format.json { render json: { result: false, errors: @address.errors.full_messages } }
        end
      end
    end

    private

    def address_params
      params.require(:address).permit(
          :first_name, :last_name, :address1, :address2, :address3, :country_id, :city, :region_id, :postcode,
          :telephone, :is_shipping, :is_billing
      )
    end
  end
end