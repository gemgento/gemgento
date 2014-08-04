module Gemgento
  class Checkout::CheckoutBaseController < Gemgento::ApplicationController
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
      @nominal = {}
      @shipping = 0
      @tax = 0
      @total = 0

      unless totals.nil?
        totals.each do |total|
          unless total[:title].include? 'Discount'
            if !total[:title].include? 'Nominal' # regular checkout values
              if total[:title].include? 'Subtotal'
                @subtotal = total[:amount].to_f
                @subtotal = current_order.subtotal if @subtotal.nil? || @subtotal == 0
              elsif total[:title].include? 'Grand Total'
                @total = total[:amount].to_f
              elsif total[:title].include? 'Tax'
                @tax = total[:amount].to_f
              elsif total[:title].include? 'Shipping'
                @shipping = total[:amount].to_f
              end
            else # checkout values for a nominal item
              if total[:title].include? 'Subtotal'
                @nominal[:subtotal] = total[:amount].to_f
                @nominal[:subtotal] = current_order.subtotal if @nominal[:subtotal] == 0
              elsif total[:title].include? 'Total'
                @nominal[:total] = total[:amount].to_f
              elsif total[:title].include? 'Tax'
                @nominal[:tax] = total[:amount].to_f
              elsif total[:title].include? 'Shipping'
                @nominal[:shipping] = total[:amount].to_f
              end
            end
          else
            code = total[:title][10..-2]
            @discounts << {code: code, amount: total[:amount]}
          end
        end

        # nominal shipping isn't calculated correctly, so we can set it based on known selected values
        if !@nominal.has_key?(:shipping) && @nominal.has_key?(:subtotal) && current_order.shipping_address
          if @shipping && @shipping > 0
            @nominal[:shipping] = @shipping
          elsif shipping_method = get_magento_shipping_method
            @nominal[:shipping] = shipping_method['price'].to_f
          else
            @nominal[:shipping] = 0.0
          end

          @nominal[:total] += @nominal[:shipping] if @nominal.has_key?(:total) # make sure the grand total reflects the shipping changes
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

    def get_magento_shipping_method
      if cookies[:shipping_methods].nil?
        shipping_methods = current_order.get_shipping_methods
      else
        shipping_methods = JSON.parse(cookies[:shipping_methods])
      end

      shipping_methods.each do |shipping_method|
        if shipping_method['code'] == current_order.shipping_method
          return shipping_method
        end
      end

      return nil
    end

    def order_payment_params
      params.require(:order).require(:order_payment).permit(:method, :cc_cid, :cc_number, :cc_type, :cc_exp_year, :cc_exp_month, :cc_owner)
    end

    def initialize_shipping_variables
      @shipping_methods = current_order.get_shipping_methods
      cookies[:shipping_methods] = @shipping_methods.to_json
    end

    def initialize_payment_variables
      unless @order_payment
        current_order.build_order_payment if current_order.order_payment.nil?
        @order_payment = current_order.order_payment
      end

      @payment_methods = current_order.get_payment_methods

      unless current_order.customer_is_guest
        @saved_credit_cards = current_user.saved_credit_cards
      else
        @saved_credit_cards = []
      end
    end

  end
end
