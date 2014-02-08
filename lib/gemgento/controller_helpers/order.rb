module Gemgento
  module ControllerHelpers
    module Orders

      def current_order
        @current_order = Gemgento::Order.get_cart(cookies[:cart]) if @current_order.nil?

        if @current_order.state != 'cart'
          @current_order = Gemgento::Order.get_cart(nil, current_store)
        end

        @current_order
      end

      def create_new_cart
        @current_order = Gemgento::Order.get_cart(nil, current_store)
      end

    end
  end
end