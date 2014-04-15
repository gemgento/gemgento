module Gemgento
  class Users::OrdersController < Users::UsersBaseController

    def index
      @orders = current_user.orders.placed.order('created_at DESC')

      respond_with @orders
    end

    def show
      @order = Gemgento::Order.find_by(increment_id: params[:id], user: current_user)

      respond_with @order
    end

  end
end