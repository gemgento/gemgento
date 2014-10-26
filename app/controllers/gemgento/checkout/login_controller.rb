module Gemgento
  class Checkout::LoginController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :set_order, :verify_guest

    respond_to :json, :html

    def show
      @user = @order.user || Gemgento::User.new
    end

    # Login user to an existing account and associate with current order.
    def login
      respond_to do |format|

        if @user = User::is_valid_login(params[:email], params[:password])
          @order.customer_is_guest = false
          @order.user = @user
          @order.push_cart_customer = true

          if @order.save
            sign_in(:user, @user)
            format.html { redirect_to checkout_address_path }
            format.json { render json: { result: true } }
          else # problem saving order
            format.html { render 'show' }
            format.json { render json: { result: false, errors: @order.errors.full_messages }, status: 422 }
          end

        else # failed login attempt
          @user = Gemgento::User.new
          flash.now[:alert] = 'Invalid username and password.'
          format.html { render 'show' }
          format.json { render json: { result: false, errors: flash[:alert] }, status: 422 }
        end
      end
    end

    # Register a new user and associate with order current order
    def register
      @user = Gemgento::User.new(user_params)
      @user.stores << current_store
      @user.user_group = Gemgento::UserGroup.find_by(code: 'General')

      respond_to do |format|

        if @user.save
          @order.customer_is_guest = false
          @order.user = @user
          @order.push_cart_customer = true

          if @order.save
            sign_in(:user, @user)
            format.html { redirect_to checkout_address_path }
            format.json { render json: { result: true } }
          else
            format.html { render 'show' }
            format.json { render json: { result: false, errors: @order.errors.full_messages }, status: 422 }
          end

        else # couldn't create user
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @user.errors.full_messages }, status: 422 }
        end
      end
    end

    # Continue with current order as guest
    def guest
      @order.customer_is_guest = true
      @user = Gemgento::User.new

      respond_to do  |format|

        if @order.update(order_params)
          format.html { redirect_to checkout_address_path }
          format.json { render json: { result: true } }
        else # problem saving order
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @order.errors.full_messages }, status: 422 }
        end
      end
    end

    private

    def set_order
      @order = current_order
    end

    def verify_guest
      if user_signed_in? && (@order.user.nil? || @order.user == current_user)
        @order.customer_is_guest = false
        @order.user = current_user
        @order.save

        response = @order.push_cart_customer_to_magento

        if response.success?
          respond_to do |format|
            format.html { redirect_to checkout_address_path }
            format.json { render json: { result: true, user: @user, order: @order } }
          end
        end
      end
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :subscribe)
    end

    def order_params
      params.require(:order).permit(:customer_email, :subscribe)
    end

  end
end