module Gemgento
  class BaseController < ActionController::Base
    before_filter :get_current_order

    def get_current_order
      @current_order ||= Gemgento::Order.get_cart(nil, cookies[:cart])
    end

  end
end

