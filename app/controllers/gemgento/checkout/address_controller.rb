module Gemgento
  class Checkout::AddressController < CheckoutController

    def show
      build_billing_address if @quote.billing_address.nil?
      build_shipping_address if @quote.shipping_address.nil?

      respond_to do |format|
        format.html
        format.json { render json: { quote: @quote, totals: @quote.totals } }
      end
    end

    def update
      @quote.push_addresses = true

      respond_to do |format|
        if @quote.update(quote_params)
          format.html { redirect_to (Config[:combined_shipping_payment] ? checkout_shipping_payment_path : checkout_shipping_path) }
          format.json { render json: { result: true, quote: @quote, totals: @quote.totals } }
        else
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @quote.errors.full_messages }, status: 422 }
        end
      end
    end

    private

    def quote_params
      params.require(:quote).permit(
          :same_as_billing,
          billing_address_attributes: [:id, :first_name, :last_name, :address1, :address2, :country_id, :city, :region_id, :postcode, :telephone],
          shipping_address_attributes: [:id, :first_name, :last_name, :address1, :address2, :country_id, :city, :region_id, :postcode, :telephone]
      )
    end

    def build_billing_address
      billing_address = current_user.default_billing_address if user_signed_in?
      billing_address = billing_address.nil? ? Address.new : billing_address.clone
      billing_address.is_billing = true
      billing_address.is_shipping = false
      @quote.build_billing_address(billing_address.attributes)
    end

    def build_shipping_address
      shipping_address = current_user.default_shipping_address if user_signed_in?
      shipping_address = shipping_address.nil? ? Address.new : shipping_address.clone
      shipping_address.is_shipping = true
      shipping_address.is_billing = false
      @quote.build_shipping_address(shipping_address.attributes)
    end

  end
end