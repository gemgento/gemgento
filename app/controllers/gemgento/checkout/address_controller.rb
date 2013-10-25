module Gemgento
  class Checkout::AddressController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user

    def show
      if current_order.user.nil? && !current_order.customer_is_guest
        current_order.user = current_user
        current_order.save
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

      @same_as_billing = true;
    end

    def update
      # create/update shipping address
      if current_order.shipping_address.nil?
        current_order.shipping_address = Address.new(shipping_address_params)
      else
        current_order.shipping_address.update_attributes(shipping_address_params)
      end

      current_order.shipping_address.address_type = 'shipping'

      # create/update billing address
      if params[:same_as_billing]
        @same_as_billing = true

        if current_order.billing_address.nil?
          current_order.billing_address = Address.new(shipping_address_params)
        else
          current_order.billing_address.update_attributes(shipping_address_params)
        end
      else
        @same_as_billing = false

        if current_order.billing_address.nil?
          current_order.billing_address = Address.new(billing_address_params)
        else
          current_order.billing_address.update_attributes(billing_address_params)
        end
      end

      current_order.billing_address.address_type = 'billing'

      # assign the current user if order is not guest checkout
      if user_signed_in?
        current_order.shipping_address.user = current_user
        current_order.billing_address.user = current_user
      else # don't push customer addresses if this is a guest checkout
        current_order.shipping_address.sync_needed = false
        current_order.billing_address.sync_needed = false
      end

      # attempt to save the addresses and respond appropriately
      if current_order.shipping_address.save && current_order.billing_address.save
        current_order.save

        # push the order information to Magento
        if user_signed_in?
          current_order.shipping_address.push
          current_order.billing_address.push
        end

        current_order.push_customer
        current_order.push_addresses

        redirect_to checkout_shipping_path
      else
        @shipping_address = current_order.shipping_address
        @billing_address = current_order.billing_address

        current_order.shipping_address.destroy
        current_order.billing_address.destroy

        render action: 'show'
      end
    end

    private

    def shipping_address_params
      params.require(:order).require(:shipping_address_attributes).permit(:fname, :lname, :address1, :address2, :country_id, :city, :region_id, :postcode, :telephone, :address_type)
    end

    def billing_address_params
      params.require(:order).require(:billing_address_attributes).permit(:fname, :lname, :address1, :address2, :country_id, :city, :region_id, :postcode, :telephone, :address_type)
    end

  end
end