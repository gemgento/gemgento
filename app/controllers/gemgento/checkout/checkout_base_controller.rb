module Gemgento
  class Checkout::CheckoutBaseController < BaseController
    ssl_required

    layout 'application'

    private

    def auth_cart_contents
      if current_order.item_count == 0
        redirect_to checkout_shopping_bag_path
      end
    end

    def auth_order_user
      # if the user is not signed in and the cart is not a guest checkout, go to login
      unless user_signed_in? || current_order.customer_is_guest
        redirect_to checkout_login_path
      end

      # if the logged in user doesn't match the cart user, go to login
      if user_signed_in? && !current_order.customer_is_guest
        if current_user != current_order.user
          redirect_to checkout_login_path
        end
      end
    end
  end
end