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
      raise 'Activity not specified' if params[:activity].nil?

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
      if user_signed_in? && (current_order.user.nil? || current_order.user == current_user)
        current_order.customer_is_guest = false
        current_order.user = current_user
        current_order.save

        current_order.push_customer

        respond_to do |format|
          format.html { redirect_to checkout_address_path }
          format.json { render json: { result: true, user: current_user, order: current_order } }
        end
      end
    end

    def login_user
      user = User::is_valid_login(params[:email], params[:password])

      result = false

      unless user.nil?
        sign_in(:user, user)
        current_order.customer_is_guest = false
        current_order.user = current_user
        current_order.save

        if current_order.push_customer
          result = true
        end
      end

      respond_to do |format|
        if result
          format.html { redirect_to checkout_address_path }
          format.json { render json: { result: true, user: current_user, order: current_order } }
        else
          flash.now[:error] = 'Invalid username and password'

          format.html { redirect_to checkout_login_path }
          format.json do
            render json: {
                result: false,
                errors: 'Invalid username and password',
                order: current_order
            }
          end
        end
      end
    end

    def register
      @user = User.new
      @user.email = params[:email]
      @user.stores << current_store
      @user.user_group = Gemgento::UserGroup.where(code: 'General').first
      @user.magento_password = params[:password]
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]

      @user.first_name = params[:first_name] unless params[:first_name].nil?
      @user.last_name = params[:last_name] unless params[:last_name].nil?

      result = false

      if @user.save
        sign_in(:user, @user)
        current_order.customer_is_guest = false
        current_order.user = current_user
        current_order.save

        Gemgento::Subscriber.add_user(@user) if params[:subscribe]

        if current_order.push_customer
          result = true
        end
      end

      respond_to do |format|
        if result
          format.html { redirect_to checkout_address_path }
          format.json { render json: { result: true, user: @user, order: current_order } }
        else
          format.html { redirect_to checkout_login_path }
          format.json { render json: { result: false, errors: @user.errors.full_messages, order: current_order } }
        end
      end
    end

    def login_guest
      raise 'Missing email parameter' if params[:email].nil?

      current_order.customer_is_guest = true
      current_order.customer_email = params[:email]

      result = (Devise::email_regexp.match(params[:email]) && current_order.save)

      respond_to do |format|
        if result
          format.html { redirect_to checkout_address_path }
          format.json { render json: { result: true, order: current_order } }
        else
          flash.now[:error] = 'Invalid email address'

          format.html { redirect_to checkout_login_path }
          format.json { render json: { result: false, errors: 'Invalid email address', order: current_order } }
        end
      end
    end

  end
end