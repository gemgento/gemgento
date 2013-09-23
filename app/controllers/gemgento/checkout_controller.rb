module Gemgento
  class CheckoutController < BaseController
    before_filter :auth_cart_contents, :except => [:thank_you]
    before_filter :auth_order_user, :except => [:login, :thank_you]
    ssl_required :login, :address, :shipping, :payment, :confirm, :thank_you, :update

    layout 'application'

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
    end

    def shipping
      set_totals
      session[:shipping_methods] = current_order.get_shipping_methods
      @shipping_methods = session[:shipping_methods]
    end

    def payment
      set_totals
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
      set_totals
      @shipping_address = current_order.shipping_address
      @billing_address = current_order.billing_address
      @payment = current_order.order_payment
      @cc_types = Gemgento::OrderPayment.cc_types
      Rails.logger.info @cc_types

      session[:shipping_methods].each do |shipping_method|
        if shipping_method[:code] == current_order.shipping_method
          @shipping_method = shipping_method
          break
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

    def auth_cart_contents
      if current_order.item_count == 0
        redirect_to '/checkout/shopping_bag'
      end
    end

    def auth_order_user
      # if the user is not signed in and the cart is not a guest checkout, go to login
      unless user_signed_in? || current_order.customer_is_guest
        redirect_to '/checkout/login'
      end

      # if the logged in user doesn't match the cart user, go to login
      if user_signed_in? && !current_order.customer_is_guest
        if current_user != current_order.user
          redirect_to '/checkout/login'
        end
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
      @user.store = Gemgento::Store.current
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
        if Devise::email_regexp.match(params[:email]) && current_order.save
          format.html { render 'gemgento/checkout/address' }
          format.js { render 'gemgento/checkout/login/login_guest_success', :layout => false }
        else
          format.html { 'gemgento/checkout/login' }
          format.js { render 'gemgento/checkout/login/login_guest_fail', :layout => false }
        end
      end
    end

    def set_addresses
      # shipping address
      if current_order.shipping_address.nil?
        current_order.shipping_address = Address.new(shipping_address_params)
      else
        current_order.shipping_address.update_attributes(shipping_address_params)
      end

      current_order.shipping_address.address_type = 'shipping'

      #billing address
      if params[:same_as_billing]
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

      current_order.billing_address.address_type = 'billing'

      #assign a user
      if user_signed_in?
        current_order.shipping_address.user = current_user
        current_order.billing_address.user = current_user
      else
        current_order.shipping_address.sync_needed = false
        current_order.billing_address.sync_needed = false
      end

      # attempt to save the addresses and respond appropriately
      respond_to do |format|

        if current_order.shipping_address.save && current_order.billing_address.save
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
          @shipping_address = current_order.shipping_address
          @billing_address = current_order.billing_address

          current_order.shipping_address.destroy
          current_order.billing_address.destroy

          format.html { redirect_to '/gemgento/checkout/address' }
          format.js { render '/gemgento/checkout/addresses/error' }
        end
      end
    end

    def set_totals
      totals = current_order.get_totals

      unless totals.nil?
        totals.each do |total|
          if total[:title] == 'Grand Total'
            @total = total[:amount].to_f
          elsif total[:title] == 'Tax'
            @tax = total[:amount].to_f
          elsif total[:title].to_s.include? 'Shipping'
            @shipping = total[:amount].to_f
          end
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


      respond_to do |format|
        if current_order.push_payment_method
          format.html { redirect_to '/gemgento/checkout/confirm' }
          format.js { render '/gemgento/checkout/payment/success' }
        else
          format.html { redirect_to '/gemgento/checkout/payment' }
          format.js { render '/gemgento/checkout/payment/error' }
        end

      end
    end

    def order_payment_params
      params.require(:order).require(:order_payment_attributes).permit(:method, :cc_cid, :cc_number, :cc_type, :cc_exp_year, :cc_exp_month)
    end

    def process_order
      current_order.enforce_cart_data

      respond_to do |format|
        if current_order.process
          create_new_cart
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