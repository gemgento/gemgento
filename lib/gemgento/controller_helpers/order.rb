module Gemgento
  module ControllerHelpers
    module Order

      def current_order
        current_order ||= Gemgento::Order.get_cart(nil, cookies[:cart])
      end

    end
  end
end