module Gemgento
  class Checkout::ShippingController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user

    def show
      set_totals
      session[:shipping_methods] = current_order.get_shipping_methods
      @shipping_methods = session[:shipping_methods]
    end

    def update
      current_order.shipping_method = params[:shipping_method]
      current_order.shipping_amount = params[params[:shipping_method]]
      current_order.push_shipping_method
      current_order.save

      respond_to do |format|
        format.html { redirect_to checkout_payment_path }
        format.js { render '/gemgento/checkout/shipping/success' }
      end
    end

  end
end