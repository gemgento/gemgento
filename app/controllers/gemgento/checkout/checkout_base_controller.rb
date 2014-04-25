module Gemgento
  class Checkout::CheckoutBaseController < ApplicationController
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

      @subtotal = 0
      @discounts = []
      @shipping = 0
      @tax = 0
      @total = 0

      unless totals.nil?
        totals.each do |total|
          puts total.inspect
          unless total[:title].include? 'Discount'
            if total[:title].include? 'Subtotal'
              @subtotal = total[:amount].to_f
            elsif total[:title].include? 'Grand Total'
              @total = total[:amount].to_f
            elsif total[:title].include? 'Tax'
              @tax = total[:amount].to_f
            elsif total[:title].include? 'Shipping'
              @shipping = total[:amount].to_f
            end
          else
            code = total[:title][10..-2]
            @discounts << { code: code, amount: total[:amount] }
          end
        end
      end
    end

    def merge_totals(hash)
      hash[:subtotal] = @subtotal
      hash[:discounts] = @discounts
      hash[:shipping] = @shipping
      hash[:tax] = @tax
      hash[:total] = @total

      return hash
    end

  end
end