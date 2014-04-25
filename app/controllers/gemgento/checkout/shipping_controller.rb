module Gemgento
  class Checkout::ShippingController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user

    respond_to :json, :html

    def show
      set_totals
      @shipping_methods = current_order.get_shipping_methods
      cookies[:shipping_methods] = @shipping_methods.to_json

      respond_to do |format|
        format.html

        response = { shipping_methods: @shipping_methods }
        response = merge_totals(response)

        format.json do
          render json: response
        end
      end
    end

    def update
      current_order.shipping_method = params[:shipping_method]
      current_order.shipping_amount = shipping_method_amount(params[:shipping_method])

      respond_to do |format|
        if current_order.push_shipping_method
          current_order.save

          format.html { redirect_to checkout_payment_path }
          format.json { render json: { result: true, order: current_order } }
        else
          flash[:error] = 'Please select a shipping method'

          format.html { redirect_to checkout_shipping_path }
          format.json { render json: { result: false, errors: 'Please select a shipping method' } }
        end
      end
    end

    private

    def shipping_method_amount(code)
      JSON.parse(cookies[:shipping_methods]).each do |shipping_method|
        if shipping_method[:code] == code
          return shipping_method[:price]
        end
      end

      return 0
    end

  end
end