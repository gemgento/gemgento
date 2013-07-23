module Gemgento
  class CheckoutController < BaseController
    before_filter :auth_order_user, :except => [:login, :register, :shopping_bag]

    layout 'application'

    def shopping_bag

    end

    def update
      raise 'Missing activity parameter' if params[:activity].nil?

      @errors = []

      case params[:activity]
        when 'set_addresses'
          set_addresses
        else
          raise "Unknown action - #{params[:activity]}"
      end
    end

    def login
      if params[:email].nil? || params[:password].nil?
        render 'gemgento/checkout/login'
      else
        user = User::is_valid_login(params[:email], params[:password])

        respond_to do |format|
          unless user.nil?
            sign_in(:users, user)

            format.html { render 'gemgento/checkout/address' }
            format.js { render '/gemgento/checkout/sessions/successful_session', :layout => false }
          else
            format.html { render 'gemgento/checkout/login' }
            format.js { render 'gemgento/checkout/sessions/errors', :layout => false }
          end
        end
      end
    end

    def register
      @user = User.new
      @user.fname = params[:fname]
      @user.lname = params[:lname]
      @user.email = params[:email]
      @user.store = Gemgento::Store.first
      @user.user_group = Gemgento::UserGroup.find_by(code: 'General')
      @user.magento_password = params[:password]
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]

      respond_to do |format|
        if @user.save
          sign_in(:users, @user)
          format.html { render 'gemgento/checkout/address' }
          format.js { render 'gemgento/checkout/registrations/successful_registration', :layout => false }
        else
          format.html { 'gemgento/checkout/login' }
          format.js { render 'gemgento/checkout/registrations/errors', :layout => false }
        end
      end
    end

    def address
      if user_signed_in?
        if current_order.shipping_address.nil?
          current_order.shipping_address = current_user.addresses.find_by(address_type: 'shipping', is_default: true)
          current_order.shipping_address = Address.new if current_order.shipping_address.nil?
        end

        if current_order.billing_address.nil?
          current_order.billing_address = current_user.addresses.find_by(address_type: 'billing', is_default: true)
          current_order.billing_address = Address.new if current_order.billing_address.nil?
        end
      else
        current_order.shipping_address = Address.new
        current_order.billing_address = Address.new
      end
    end

    def confirm

    end

    private

      def auth_order_user
        logger.info 'here'
        unless user_signed_in? || current_order.customer_is_guest
          logger.info 'here'
          redirect_to '/checkout/login'
        end
      end

      def set_addresses
        current_order.shipping_address = Address.new(shipping_address_params)

        respond_to do |format|

          if current_order.shipping_address.save # try to set the shipping address attributes
            if params[:same_as_billing]
              current_order.billing_address = Address.new(shipping_address_params) # set the billing address attributes the same as shipping
            else
              current_order.billing_address = Address.new(billing_address_params)
            end

            if current_order.billing_address.save
              logger.info 'Great Success'
              current_order.save
              format.html { redirect_to '/gemgento/checkout/addresses/shipping' }
              format.js { render '/gemgento/checkout/addresses/success' }
            else
              logger.info 'Billing failure'
              format.html { redirect_to '/gemgento/checkout/address' }
              format.js { render '/gemgento/checkout/addresses/error' }
            end
          else
            logger.info 'Shipping failure'
            format.html { redirect_to '/gemgento/checkout/address' }
            format.js { render '/gemgento/checkout/addresses/error' }
          end
        end
      end

      def shipping_address_params
        params.require(:order).require(:shipping_address_attributes).permit(:fname, :lname, :country_id, :city, :region_id, :postcode, :telephone)
      end

      def billing_address_params
        params.require(:order).require(:billing_address_attributes).permit(:fname, :lname, :country_id, :city, :region_id, :postcode, :telephone)
      end

  end
end