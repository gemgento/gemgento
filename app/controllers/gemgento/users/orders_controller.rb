module Gemgento
  class Users::OrdersController < Users::UsersBaseController

    def index
      @orders = current_user.orders.placed.order('created_at DESC')
    end

    def show

    end

  end
end