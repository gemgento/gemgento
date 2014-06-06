module Gemgento
  class Users::RegistrationSessionController < Users::UsersBaseController

    skip_before_filter :auth_user

    respond_to :json, :html

    def new
      @user = Gemgento::User.new
    end

    def create
      case params[:activity]
        when 'sign_in'
          create_session
        when 'register'
          create_registration
        else
          raise "Unknown action - #{params[:activity]}"
      end
    end

    private

    def create_session
      @user = User::is_valid_login(user_session_params[:email], user_session_params[:password])
      result = false

      unless @user.nil?
        sign_in(:user, @user)
        result = true
      end

      respond_to do |format|
        if result
          format.html { redirect_to after_sign_in_path }
          format.json { render json: { result: true, user: current_user } }
        else
          @user = User.new
          @user.email = user_session_params[:email]
          flash.keep[:error] = 'Invalid username and password'

          format.html { render 'new' }
          format.json do
            render json: {
                result: false,
                errors: 'Invalid username and password',
            }
          end
        end
      end
    end

    def create_registration
      @user = User.new(user_registration_params)
      @user.stores << current_store
      @user.user_group = Gemgento::UserGroup.where(code: 'General').first

      respond_to do |format|
        if @user.save
          sign_in(:user, @user)
          Gemgento::Subscriber.add_user(@user) if params[:subscribe]

          format.html { redirect_to after_register_path }
          format.json { render json: { result: true, user: @user, order: current_order } }
        else
          format.html { render 'new' }
          format.json { render json: { result: false, errors: @user.errors.full_messages, order: current_order } }
        end
      end
    end

    private

    def user_session_params
      params.require(:user).permit(:email, :password)
    end

    def user_registration_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def after_sign_in_path
      edit_user_registration_path
    end

    def after_register_path
      edit_user_registration_path
    end

  end
end