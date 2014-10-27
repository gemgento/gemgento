module Gemgento
  class Checkout::ShippingController < CheckoutController
    respond_to :json, :html

    def show
      @shipping_methods = current_order.get_shipping_methods
      cookies[:shipping_methods] = @shipping_methods.to_json

      respond_to do |format|
        format.html
        format.json { render json: { shipping_methods: @shipping_methods, totals: current_order.totals } }
      end
    end

    def update
      respond_to do |format|
        if current_order.set_shipping_method(params[:shipping_method], JSON.parse(cookies[:shipping_methods]))
          format.html { redirect_to checkout_payment_path }
          format.json { render json: { result: true, order: current_order } }
        else
          flash[:error] = 'Please select a shipping method'
          format.html { redirect_to checkout_shipping_path }
          format.json { render json: { result: false, errors: 'Please select a shipping method' } }
        end
      end
    end

  end
end