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
          format.json { render json: { result: false, errors: @quote.errors.full_messages } }
        end
      end
    end

    def update_old
      @billing_address = Address.new(billing_address_params)
      @shipping_address = Address.new(shipping_address_params)

      # validate addresses before continuing
      if params[:same_as_billing] && !@billing_address.valid?
        respond_to do |format|
          format.html do 
            @quote.build_billing_address(billing_address_params).valid?
            @quote.build_shipping_address(shipping_address_params).valid?
            render 'gemgento/checkout/address/show'
          end
          format.json do
            render json: {
                result: false,
                errors: {
                    billing_address: @billing_address.errors.full_messages
                }
            }
          end
        end
      elsif !params[:same_as_billing] && (!@billing_address.valid? || !@shipping_address.valid?)
        respond_to do |format|
          format.html do 
            @quote.build_billing_address(billing_address_params).valid?
            @quote.build_shipping_address(shipping_address_params).valid?
            render 'gemgento/checkout/address/show'
          end
          format.json do
            render json: {
                result: false,
                errors: {
                    billing_address: @billing_address.errors.full_messages,
                    shipping_address: @shipping_address.errors.full_messages
                }
            }
          end
        end
      else # addresses are valid

        # create/update billing address
        if @quote.billing_address.nil?
          @quote.billing_address = Address.new(billing_address_params)
        else
          @quote.billing_address.update_attributes(billing_address_params)
        end

        @quote.billing_address.address_type = 'billing'

        # create/update shipping address
        if params[:same_as_billing]
          @same_as_billing = true

          if @quote.shipping_address.nil?
            @quote.shipping_address = Address.new(billing_address_params)
          else
            @quote.shipping_address.update_attributes(billing_address_params)
          end
        else
          @same_as_billing = false

          if @quote.shipping_address.nil?
            @quote.shipping_address = Address.new(shipping_address_params)
          else
            @quote.shipping_address.update_attributes(shipping_address_params)
          end
        end

        @quote.shipping_address.address_type = 'shipping'

        @quote.shipping_address.sync_needed = false
        @quote.billing_address.sync_needed = false

        respond_to do |format|
          result = false

          # attempt to save the addresses and respond appropriately
          if @quote.billing_address.save && @quote.shipping_address.save
            @quote.save
            @quote.push_cart_customer_to_magento if @quote.customer_is_guest
            result = true if @quote.push_addresses
          end

          unless result
            # the addresses were not saved, so make them instance variables and disassociate them from the order
            @billing_address = @quote.billing_address
            @shipping_address = @quote.shipping_address

            @quote.shipping_address.destroy
            @quote.billing_address.destroy
          end

          if result
            Address.save_from_order(
                @quote,
                params[:save_billing],
                params[:save_shipping],
                params[:same_as_billing]
            ) unless @quote.customer_is_guest


            format.html do
              if Config[:combined_shipping_payment]
                redirect_to checkout_shipping_payment_path
              else
                redirect_to checkout_shipping_path
              end
            end
            format.json { render json: { result: true, order: @quote } }
          else
            format.html do
              @quote.build_billing_address(billing_address_params).valid?
              @quote.build_shipping_address(shipping_address_params).valid?
              render 'gemgento/checkout/address/show'
            end
            format.json do
              render json: {
                  result: false,
                  errors: {
                      billing_address: @billing_address.errors.full_messages,
                      shipping_address: @shipping_address.errors.full_messages
                  }
              }
            end
          end
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