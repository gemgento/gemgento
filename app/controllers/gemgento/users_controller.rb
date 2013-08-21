module Gemgento
  class UsersController < BaseController
    before_filter :auth_user

    layout 'application'

    def show

    end

    def update
      user = User.find(params[:id])
      user.update_attributes!(user_params)
      redirect_to user
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