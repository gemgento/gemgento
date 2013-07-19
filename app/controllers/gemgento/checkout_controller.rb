module Gemgento
  class CheckoutController < BaseController
    before_filter :auth_order_user, :except => [:login, :register, :shopping_bag]

    layout 'application'

    def shopping_bag

    end

    def login
      if params[:email].nil? || params[:password].nil?
        render 'gemgento/checkout/login'
      else
        user = User::is_valid_login(params[:email], params[:password])

        respond_to do |format|
          unless user.nil?
            sign_in(:user, user)

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
          sign_in(:user, @user)
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
        @shipping_address = current_user.get_default_address('shipping')
        @billing_address = current_user.get_default_address('billing')
      else
        @shipping_address = Address.new
        @billing_address = Address.new
      end
    end

    def shipping

    end

    def payment

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

  end
end