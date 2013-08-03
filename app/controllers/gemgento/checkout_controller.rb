module Gemgento
  class CheckoutController < BaseController
    before_filter :auth_order_user, :except => [:login, :shopping_bag]

    layout 'application'

    def shopping_bag

    end

    def login
      if params[:activity].nil?
        render 'gemgento/checkout/login'
      else
        case params[:activity]
          when 'login_user'
            login_user
          when 'login_guest'
            login_guest
          when 'register'
            register
          else
            raise "Unknown action - #{params[:activity]}"
        end
      end
    end

    def address
      if current_order.user.nil? && !current_order.customer_is_guest
        current_order.user = current_user
        current_order.save
      end

      current_order.push_cart if current_order.magento_quote_id.nil?

      if user_signed_in?
        if current_order.shipping_address.nil?
          current_order.shipping_address = current_user.addresses.where(address_type: 'shipping', is_default: true).first
          current_order.shipping_address = Address.new if current_order.shipping_address.nil?
        end

        if current_order.billing_address.nil?
          current_order.billing_address = current_user.addresses.where(address_type: 'billing', is_default: true).first
          current_order.billing_address = Address.new if current_order.billing_address.nil?
        end
      else
        current_order.shipping_address = Address.new
        current_order.billing_address = Address.new
      end
    end

    def shipping
      session[:shipping_methods] = current_order.get_shipping_methods
      @shipping_methods = session[:shipping_methods]
    end

    def payment
      #@payment_methods = current_order.get_payment_methods

      @card_types = {
          'Credit card type' => nil,
          Visa: 'VI',
          MasterCard: 'MC',
          'American Express' => 'AE'
      }

      @exp_years = []
      Time.now.year.upto(Time.now.year + 10) do |year|
        @exp_years << year
      end

      @exp_months = []
      1.upto(12) do |month|
        @exp_months << month
      end

      current_order.order_payment = OrderPayment.new if current_order.order_payment.nil?
    end

    def confirm
      @totals = current_order.get_totals
      @shipping_address = current_order.shipping_address
      @billing_address = current_order.billing_address
      @payment = current_order.order_payment

      session[:shipping_methods].each do |shipping_method|
        if shipping_method[:code] == current_order.shipping_method
          @shipping_method = shipping_method
          break
        end
      end

      current_order.get_totals.each do |total|
        if total[:title] == 'Grand Total'
          @total = total[:amount]
        end
      end
    end

    def thank_you

    end

    def update
      raise 'Missing activity parameter' if params[:activity].nil?

      @errors = []

      case params[:activity]
        when 'set_addresses'
          set_addresses
        when 'set_shipping_method'
          set_shipping_method
        when 'set_payment_method'
          set_payment_method
        when 'process_order'
          process_order
        else
          raise "Unknown action - #{params[:activity]}"
      end
    end

    private

    def auth_order_user
      unless user_signed_in? || current_order.customer_is_guest
        redirect_to '/checkout/login'
      end
    end

    def login_user
      user = User::is_valid_login(params[:email], params[:password])

      respond_to do |format|
        unless user.nil?
          sign_in(:user, user)
          current_order.user = current_user
          current_order.save

          format.html { render 'gemgento/checkout/address' }
          format.js { render '/gemgento/checkout/login/login_success', :layout => false }
        else
          format.html { render 'gemgento/checkout/login' }
          format.js { render 'gemgento/checkout/login/login_fail', :layout => false }
        end
      end
    end

    def register
      @user = User.new
      @user.fname = params[:fname]
      @user.lname = params[:lname]
      @user.email = params[:email]
      @user.store = Gemgento::Store.first
      @user.user_group = Gemgento::UserGroup.where(code: 'General').first
      @user.magento_password = params[:password]
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]

      respond_to do |format|
        if @user.save
          sign_in(:user, @user)
          current_order.user = current_user
          current_order.save

          format.html { render 'gemgento/checkout/address' }
          format.js { render 'gemgento/checkout/login/registration_success', :layout => false }
        else
          format.html { 'gemgento/checkout/login' }
          format.js { render 'gemgento/checkout/login/registration_fail', :layout => false }
        end
      end
    end

    def login_guest
      raise 'Missing email parameter' if params[:email].nil?

      current_order.customer_is_guest = true
      current_order.customer_email = params[:email]

      respond_to do |format|
        if current_order.save
          format.html { render 'gemgento/checkout/address' }
          format.js { render 'gemgento/checkout/login/login_guest_success', :layout => false }
        else
          format.html { 'gemgento/checkout/login' }
          format.js { render 'gemgento/checkout/login/login_guest_fail', :layout => false }
        end
      end
    end

    def set_addresses
      if current_order.shipping_address.nil?
        current_order.shipping_address = Address.new(shipping_address_params)
        current_order.shipping_address.address_type = 'shipping'
      else
        current_order.shipping_address.update_attributes(shipping_address_params)
        current_order.shipping_address.address_type = 'shipping'
      end

      if user_signed_in?
        current_order.shipping_address.user = current_user
      else
        current_order.shipping_address.sync_needed = false
      end

      respond_to do |format|

        if current_order.shipping_address.save # try to set the shipping address attributes

          if params[:same_as_billing] # set the billing address attributes the same as shipping

            if current_order.billing_address.nil?
              current_order.billing_address = Address.new(shipping_address_params)
            else
              current_order.billing_address.update_attributes(shipping_address_params)
            end
          else
            if current_order.billing_address.nil?
              current_order.billing_address = Address.new(billing_address_params)
            else
              current_order.billing_address.update_attributes(billing_address_params)
            end
          end

          current_order.billing_address.address_type = 'billing' # if user selected 'billing same as shipping' we need to force the correct type

          if user_signed_in?
            current_order.billing_address.user = current_user
          else
            current_order.billing_address.sync_needed = false
          end

          if current_order.billing_address.save
            current_order.save

            if user_signed_in?
              current_order.shipping_address.push
              current_order.billing_address.push
            end

            current_order.push_customer
            current_order.push_addresses

            format.html { redirect_to '/gemgento/checkout/shipping' }
            format.js { render '/gemgento/checkout/addresses/success' }
          else
            current_order.shipping_address.destroy

            format.html { redirect_to '/gemgento/checkout/address' }
            format.js { render '/gemgento/checkout/addresses/error' }
          end
        else
          format.html { redirect_to '/gemgento/checkout/address' }
          format.js { render '/gemgento/checkout/addresses/error' }
        end
      end
    end

    def shipping_address_params
      params.require(:order).require(:shipping_address_attributes).permit(:fname, :lname, :address1, :address2, :country_id, :city, :region_id, :postcode, :telephone, :address_type)
    end

    def billing_address_params
      params.require(:order).require(:billing_address_attributes).permit(:fname, :lname, :address1, :address2, :country_id, :city, :region_id, :postcode, :telephone, :address_type)
    end

    def set_shipping_method
      current_order.shipping_method = params[:shipping_method]
      current_order.shipping_amount = params[params[:shipping_method]]
      current_order.push_shipping_method
      current_order.save

      respond_to do |format|
        format.html { redirect_to '/gemgento/checkout/payment' }
        format.js { render '/gemgento/checkout/shipping/success' }
      end
    end

    def set_payment_method
      if current_order.order_payment.nil?
        current_order.order_payment = OrderPayment.new(order_payment_params)
      else
        current_order.order_payment.update_attributes(order_payment_params)
      end

      current_order.order_payment.cc_owner = "#{current_order.billing_address.fname} #{current_order.billing_address.lname}"
      current_order.order_payment.cc_last4 = current_order.order_payment.cc_number[-4..-1]
      current_order.order_payment.save

      current_order.push_payment_method

      respond_to do |format|
        format.html { redirect_to '/gemgento/checkout/confirm' }
        format.js { render '/gemgento/checkout/payment/success' }
      end
    end

    def order_payment_params
      params.require(:order).require(:order_payment_attributes).permit(:method, :cc_cid, :cc_number, :cc_type, :cc_exp_year, :cc_exp_month)
    end

    def process_order
      respond_to do |format|
        if current_order.process
          format.html { redirect_to '/checkout/thank_you' }
          format.js { render 'gemgento/checkout/confirm/success' }
        else
          format.html { redirect_to '/checkout/confirm' }
          format.js { render 'gemgento/checkout/confirm/error' }
        end
      end
    end
  end
end