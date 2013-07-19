module Gemgento
  class UsersController < BaseController
    before_filter :auth_user

    layout 'application'

    def account

    end

    def info

    end

    def address

    end

    private

    def auth_user
      redirect_to '/users/sign_in' unless user_signed_in?
    end

  end
end