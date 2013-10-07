module Gemgento
  class UsersController < BaseController
    before_filter :auth_user

    ssl_required :show, :update

    layout 'application'

    def show
      @user = current_user
    end

    def update
      user = User.find(params[:id])
      user.update_attributes!(user_params)
      redirect_to user
    end

    def edit
      @user = current_user
    end

    private

    def auth_user
      redirect_to new_user_session_path unless user_signed_in?
    end

    def user_params
      params.require(:user).permit(:fname, :lname, :email, :mname, :prefix, :suffix)
    end

  end
end