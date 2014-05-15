module Gemgento
  class UsersController < Gemgento::ApplicationController
    before_filter :auth_user, except: [:update, :index]

    respond_to :json, :html

    def index
      @user = current_user

      respond_to do |format|
        format.html
        format.json { render json: @user.as_json({ store: current_store }) }
      end
    end

    def show
      @user = current_user

      respond_to do |format|
        format.html
        format.json { render json: @user.as_json({ store: current_store }) }
      end
    end

    private

    def auth_user
      redirect_to new_user_session_path unless user_signed_in?
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :middle_name, :prefix, :suffix, :password, :password_confirmation)
    end

  end
end