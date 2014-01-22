module Gemgento
  class Checkout::LoginController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :verify_guest

    respond_to :json, :html

    def show
      @user = current_user

      respond_with @user
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

      unless user.nil?
        sign_in(:user, user)
        current_order.customer_is_guest = false
        current_order.user = current_user
        current_order.save

        respond_with current_order, location: checkout_address_path
      else
        flash.now[:error] = 'Invalid username and password'

        respond_with @user, location: checkout_login_path
      end
    end

    def register
      @user = User.new
      @user.email = params[:email]
      @user.store = Gemgento::Store.current
      @user.user_group = Gemgento::UserGroup.where(code: 'General').first
      @user.magento_password = params[:password]
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]

      if @user.save
        sign_in(:user, @user)
        current_order.customer_is_guest = false
        current_order.user = current_user
        current_order.save

        respond_with current_order, location: checkout_address_path
      else
        respond_with @user, location: checkout_login_path
      end
    end

    def login_guest
      raise 'Missing email parameter' if params[:email].nil?

      current_order.customer_is_guest = true
      current_order.customer_email = params[:email]

      if Devise::email_regexp.match(params[:email]) && current_order.save
        respond_with current_order, location: checkout_address_path
      else
        flash.now[:error] = 'Invalid email address'
        respond_with @user, location: checkout_login_path
      end
    end

  end
end