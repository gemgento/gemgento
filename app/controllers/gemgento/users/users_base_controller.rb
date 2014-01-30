module Gemgento
  class Users::UsersBaseController < BaseController
    before_filter :auth_user

    respond_to :json, :html

    ssl_required

    private

    def auth_user
      redirect_to new_user_session_path unless user_signed_in?
    end

  end
end