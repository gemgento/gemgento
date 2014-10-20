module Gemgento
  class User::RegistrationSessionController < User::BaseController

    skip_before_filter :auth_user
    before_filter :set_user_instances

    respond_to :json, :html
    
    def new
      @existing_user = Gemgento::User.new
      @new_user = Gemgento::User.new
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

    def set_user_instances
      @existing_user = Gemgento::User.new
      @new_user = Gemgento::User.new
    end

    def create_session
      @existing_user = User::is_valid_login(user_session_params[:email], user_session_params[:password])
      result = false

      unless @existing_user.nil?
        sign_in(:user, @existing_user)
        result = true
      end

      respond_to do |format|
        if result
          format.html { redirect_to after_sign_in_path }
          format.json { render json: { result: true, user: current_user } }
        else
          @existing_user = Gemgento::User.new(email: user_session_params[:email])
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
      @new_user = Gemgento::User.new(user_registration_params)
      @new_user.stores << current_store
      @new_user.user_group = Gemgento::UserGroup.where(code: 'General').first

      respond_to do |format|
        if @new_user.save
          sign_in(:user, @new_user)
          Gemgento::Subscriber.add_user(@new_user) if params[:subscribe]

          format.html { redirect_to after_register_path }
          format.json { render json: { result: true, user: @new_user, order: current_order } }
        else
          format.html { render 'new' }
          format.json { render json: { result: false, errors: @new_user.errors.full_messages, order: current_order } }
        end
      end
    end

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
