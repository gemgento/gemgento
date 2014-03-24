module Gemgento
  class Checkout::AddressController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user

    respond_to :json, :html

    def show
      if current_order.user.nil? && !current_order.customer_is_guest
        current_order.user = current_user
        current_order.save
        current_order.push_customer
      end

      current_order.push_cart if current_order.magento_quote_id.nil?

      if user_signed_in?
        if current_order.shipping_address.nil?
          current_order.shipping_address = current_user.addresses.where(address_type: 'shipping', is_default: true).first
          current_order.shipping_address = current_user.addresses.where(address_type: 'shipping').first if current_order.shipping_address.nil?
          current_order.shipping_address = Address.new if current_order.shipping_address.nil?
        end

        if current_order.billing_address.nil?
          current_order.billing_address = current_user.addresses.where(address_type: 'billing', is_default: true).first
          current_order.billing_address = current_user.addresses.where(address_type: 'billing').first if current_order.billing_address.nil?
          current_order.billing_address = Address.new if current_order.billing_address.nil?
        end
      else
        current_order.shipping_address = Address.new if current_order.shipping_address.nil?
        current_order.billing_address = Address.new if current_order.billing_address.nil?
      end

      @same_as_billing = true

      respond_with current_order
    end

    def update
      # validate addresses before continuing
      if params[:same_as_billing] && !Address.new(billing_address_params).valid?
        @billing_address = Address.create(billing_address_params)
        respond_to do |format|
          format.html { render checkout_address }
          format.json do
            render json: {
                result: false,
                errors: {
                    billing_address: @billing_address.errors.full_messages
                }
            }
          end
        end
      elsif !params[:same_as_billing] && (!Address.new(billing_address_params).valid? || !Address.new(shipping_address_params).valid?)
        @billing_address = Address.create(billing_address_params)
        @shipping_address = Address.create(shipping_address_params)
        respond_to do |format|
          format.html { render checkout_address }
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
        if current_order.billing_address.nil?
          current_order.billing_address = Address.new(billing_address_params)
        else
          current_order.billing_address.update_attributes(billing_address_params)
        end

        current_order.billing_address.address_type = 'billing'

        # create/update shipping address
        if params[:same_as_billing]
          @same_as_billing = true

          if current_order.shipping_address.nil?
            current_order.shipping_address = Address.new(billing_address_params)
          else
            current_order.shipping_address.update_attributes(billing_address_params)
          end
        else
          @same_as_billing = false

          if current_order.shipping_address.nil?
            current_order.shipping_address = Address.new(shipping_address_params)
          else
            current_order.shipping_address.update_attributes(shipping_address_params)
          end
        end

        current_order.shipping_address.address_type = 'shipping'

        current_order.shipping_address.sync_needed = false
        current_order.billing_address.sync_needed = false

        respond_to do |format|
          result = false

          # attempt to save the addresses and respond appropriately
          if current_order.billing_address.save && current_order.shipping_address.save
            current_order.save

            current_order.push_customer if current_order.customer_is_guest
            result = true if current_order.push_addresses
          end

          unless result
            # the addresses were not saved, so make them instance variables and disassociate them from the order
            @billing_address = current_order.billing_address
            @shipping_address = current_order.shipping_address

            current_order.shipping_address.destroy
            current_order.billing_address.destroy
          end

          if result
            format.html { render checkout_shipping_path }
            format.json { render json: { result: true, order: current_order } }
          else
            format.html { render checkout_address }
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

    def shipping_address_params
      params.require(:order).require(:shipping_address_attributes).permit(:first_name, :last_name, :address1, :address2, :country_id, :city, :region_id, :postcode, :telephone, :address_type)
    end

    def billing_address_params
      params.require(:order).require(:billing_address_attributes).permit(:first_name, :last_name, :address1, :address2, :country_id, :city, :region_id, :postcode, :telephone, :address_type)
    end

  end
end