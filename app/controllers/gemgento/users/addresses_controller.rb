module Gemgento
  class Users::AddressesController < Users::UsersBaseController

    def index
      @new_shipping_address = Address.new
      @default_shipping_address = current_user.default_shipping_address
      @shipping_addresses = current_user.shipping_addresses

      @new_billing_address = Address.new
      @default_billing_address = current_user.default_billing_address
      @billing_addresses = current_user.billing_addresses

      respond_to do |format|
        format.html
        format.json { render json: current_user.address_book }
      end
    end

    def show
      @address = current_user.address_book.find(id: params[:id])
      respond_with @address
    end

    def new
      @address = Gemgento::Address.new
    end

    def edit
      @address = current_user.address_book.find(id: params[:id])
      respond_with @address
    end

    def create
      @address = Address.new(address_params)
      @address.user = current_user

      respond_to do |format|
        if @address.save
          format.html { redirect_to action: 'index', notice: 'The new address was created successfully.' }
          format.js { render '/gemgento/users/addresses/success' }
          format.json { render json: { result: true, address: @address } }
        else
          format.html { render 'new' }
          format.js { render '/gemgento/users/addresses/errors' }
          format.json { render json: { result: false, errors: @address.errors.full_messages } }
        end
      end
    end

    def update
      @address = current_user.address_book.find(params[:id])

      respond_to do |format|
        if @address.update_attributes(address_params)
          format.html { redirect_to action: 'index', notice: 'The new address was updated successfully.' }
          format.js { render '/gemgento/users/addresses/success' }
          format.json { render json: { result: true, address: @address } }
        else
          format.html { render 'edit' }
          format.js { render '/gemgento/users/addresses/errors' }
          format.json { render json: { result: false, errors: @address.errors.full_messages } }
        end
      end
    end

    def destroy
      current_user.address_book.find(params[:id]).destroy

      respond_to do |format|
        format.html
        format.json { render json: { result: true } }
      end
    end

    private

    def address_params
      params.require(:address).permit(:first_name, :last_name, :address1, :address2, :address3, :country_id, :city, :region_id, :postcode, :telephone, :is_default, :address_type)
    end
  end
end