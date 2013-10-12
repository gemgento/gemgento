module Gemgento
  class Checkout::LoginController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :verify_guest

    def show
      render :layout => false if request.headers['X-PJAX']
    end

    def update
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

    private

    def verify_guest
      if user_signed_in? && current_order.user.nil?
        current_order.user = current_user
        redirect_to checkout_address_path
      elsif user_signed_in? && current_order.user == current_user
        redirect_to checkout_address_path
      end
    end

    def login_user
      user = User::is_valid_login(params[:email], params[:password])

      respond_to do |format|
        unless user.nil?
          sign_in(:user, user)
          current_order.customer_is_guest = false
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
          current_order.customer_is_guest = false
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

  end
end