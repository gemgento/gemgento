module Gemgento
  class Checkout::ConfirmController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user

    def show
      set_totals
      @shipping_address = current_order.shipping_address
      @billing_address = current_order.billing_address
      @payment = current_order.order_payment
      @cc_types = Gemgento::OrderPayment.cc_types
      Rails.logger.info @cc_types

      session[:shipping_methods].each do |shipping_method|
        if shipping_method[:code] == current_order.shipping_method
          @shipping_method = shipping_method
          break
        end
      end
    end

    def update
      current_order.enforce_cart_data

      respond_to do |format|
        if current_order.process
          create_new_cart
          format.html { redirect_to checkout_thank_you_path }
          format.js { render 'gemgento/checkout/confirm/success' }
        else
          format.html { redirect_to checkout_confirmation_path }
          format.js { render 'gemgento/checkout/confirm/error' }
        end
      end
    end

  end
end