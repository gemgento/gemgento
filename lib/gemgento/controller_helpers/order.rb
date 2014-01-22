module Gemgento
  module ControllerHelpers
    module Order

      def current_order
        @current_order = Gemgento::Order.get_cart(cookies[:cart]) if @current_order.nil?

        if @current_order.state != 'cart'
          @current_order = Gemgento::Order.get_cart
        end

        @current_order
      end

      def create_new_cart
        @current_order = Gemgento::Order.get_cart
      end

    end
  end
end