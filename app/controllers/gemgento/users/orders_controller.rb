module Gemgento
  class Users::OrdersController < Users::UsersBaseController

    def index
      @orders = current_user.orders.placed.order('created_at DESC')
    end

    def show
      @order = Gemgento::Order.find_by(id: params[:id], user: current_user)
    end

  end
end