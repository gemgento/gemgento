module Gemgento
  class OrdersController < ApplicationController

    def show
      case current_quote.state
        when 'cart'
          render 'cart'
      end
    end

  end
end