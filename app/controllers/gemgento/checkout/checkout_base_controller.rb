module Gemgento
  class Checkout::CheckoutBaseController < BaseController
    ssl_required

    private

    def auth_cart_contents
      if current_order.item_count == 0
        redirect_to checkout_shopping_bag_path
      end
    end

    def auth_order_user
      # if the user is not signed in and the cart is not a guest checkout, go to login
      if !user_signed_in? && !current_order.customer_is_guest
        redirect_to checkout_login_path
      end
    end

    def set_totals
      totals = current_order.get_totals

      unless totals.nil?
        totals.each do |total|
          if total[:title] == 'Grand Total'
            @total = total[:amount].to_f
          elsif total[:title] == 'Tax'
            @tax = total[:amount].to_f
          elsif total[:title].to_s.include? 'Shipping'
            @shipping = total[:amount].to_f
          end
        end
      end
    end

  end
end