module Gemgento
  class OrdersController < Gemgento::ApplicationController
    ssl_allowed

    def show
      case current_order.state
        when 'cart'
          render 'cart'
      end
    end

    def create
      @errors = []

      # save the order and mark is as the current cart
      current_order.save
      session[:cart] = current_order.id

      add_item

      respond_to do |format|
        format.html { render 'gemgento/checkout/shopping_bag' }
        format.js { render '/gemgento/order/add_item', :layout => false }
      end
    end

  end
end