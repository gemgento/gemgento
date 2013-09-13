module Gemgento
  class Users::OrdersController < BaseController
    before_filter :auth_user

    ssl_required :index, :show

    layout 'application'

    def index

    end

    def show

    end

    private

    def auth_user
      redirect_to new_user_session_path unless user_signed_in?
    end

  end
end