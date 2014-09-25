module Gemgento
  class User::BaseController < Gemgento::ApplicationController
    before_filter :auth_user

    respond_to :json, :html

    private

    def auth_user
      redirect_to new_user_session_path unless user_signed_in?
    end

  end
end