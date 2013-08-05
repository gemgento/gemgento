module Gemgento
  module ControllerHelpers
    module Order

      def current_order
        @current_order ||= Gemgento::Order.get_cart(cookies[:cart])
      end

      def create_new_cart
        @current_rder = Gemgento::Order.get_cart
      end

    end
  end
end