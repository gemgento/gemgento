module Gemgento
  class OrdersController < ApplicationController

    def show
      case current_order.state
        when 'cart'
          render 'cart'
      end
    end

  end
end