module Gemgento
  class Users::UsersBaseController < BaseController
    before_filter :auth_user
    ssl_required

    layout 'application'

    private

    def auth_user
      redirect_to new_user_session_path unless user_signed_in?
    end

  end
end