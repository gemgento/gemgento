module Gemgento
  class Checkout::LoginController < CheckoutController
    skip_before_filter :validate_quote_user
    before_filter :verify_guest

    def show
      @user = @quote.user || User.new

      respond_to do |format|
        format.html
        format.json { render json: { user: @user, quote: @quote } }
      end
    end

    # Login user to an existing account and associate with current order.
    def login
      respond_to do |format|

        if @user = User::is_valid_login(params[:email], params[:password])
          @quote.customer_is_guest = false
          @quote.user = @user
          @quote.push_customer = true

          if @quote.save
            sign_in(:user, @user)
            format.html { redirect_to after_checkout_login_path }
            format.json { render json: { result: true } }
          else # problem saving order
            format.html { render 'show' }
            format.json { render json: { result: false, errors: @quote.errors }, status: 422 }
          end

        else # failed login attempt
          @user = User.new
          flash.now[:alert] = 'Invalid username and password.'
          format.html { render 'show' }
          format.json { render json: { result: false, errors: flash[:alert] }, status: 422 }
        end
      end
    end

    # Register a new user and associate with order current order
    def register
      @user = User.new(user_params)
      @user.stores << current_store
      @user.user_group = UserGroup.find_by(code: 'General')

      respond_to do |format|

        if @user.save
          @quote.customer_is_guest = false
          @quote.user = @user
          @quote.push_customer = true

          if @quote.save
            sign_in(:user, @user)
            format.html { redirect_to after_checkout_login_path }
            format.json { render json: { result: true } }
          else
            format.html { render 'show' }
            format.json { render json: { result: false, errors: @quote.errors }, status: 422 }
          end

        else # couldn't create user
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @user.errors }, status: 422 }
        end
      end
    end

    # Continue with current order as guest
    def guest
      @quote.customer_is_guest = true
      @user = User.new

      respond_to do  |format|

        if @quote.update(quote_params)
          format.html { redirect_to after_checkout_login_path }
          format.json { render json: { result: true } }
        else # problem saving order
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @quote.errors }, status: 422 }
        end
      end
    end

    private

    def verify_guest
      if user_signed_in?
        @quote.customer_is_guest = false
        @quote.user = current_user
        @quote.push_customer = true

        respond_to do |format|
          if @quote.save
            format.html { redirect_to after_checkout_login_path }
            format.json { render json: { result: true, user: @user, quote: @quote } }

          else
            @user = User.new
            format.html { render 'show' }
            format.json { render json: { result: false, errors: @quote.errors } }
          end
        end
      end
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :subscribe)
    end

    def quote_params
      params.require(:quote).permit(:customer_email, :subscribe)
    end

    def after_checkout_login_path
      checkout_address_path
    end

  end
end