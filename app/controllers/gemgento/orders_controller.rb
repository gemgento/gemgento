module Gemgento
  class OrdersController < Gemgento::ApplicationController

    def show
      case current_order.state
        when 'cart'
          render 'cart'
      end
    end

  end
end