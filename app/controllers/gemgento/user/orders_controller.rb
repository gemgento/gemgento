module Gemgento
  class User::OrdersController < User::BaseController

    def index
      @orders = current_user.orders.placed.order('created_at DESC')

      respond_with @orders
    end

    def show
      @order = Order.find_by(increment_id: params[:id], user: current_user)

      respond_with @order
    end

  end
end