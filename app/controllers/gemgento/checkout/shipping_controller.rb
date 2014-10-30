module Gemgento
  class Checkout::ShippingController < CheckoutController
    respond_to :json, :html

    def show
      @shipping_methods = @quote.get_shipping_methods
      cookies[:shipping_methods] = @shipping_methods.to_json

      respond_to do |format|
        format.html
        format.json { render json: { quote: @quote, shipping_methods: @shipping_methods, totals: @quote.totals } }
      end
    end

    def update
      @quote.shipping_amount = @quote.get_shipping_amount(quote_params[:shipping_method], JSON.parse(cookies[:shipping_methods], symbolize_names: true))
      @quote.push_shipping_method = true

      respond_to do |format|
        if @quote.set_shipping_method(params[:shipping_method], JSON.parse(cookies[:shipping_methods]))
          format.html { redirect_to checkout_payment_path }
          format.json { render json: { result: true, order: @quote, totals: @quote.totals } }
        else
          flash[:error] = 'Please select a shipping method'
          format.html { redirect_to checkout_shipping_path }
          format.json { render json: { result: false, errors: 'Please select a shipping method' }, status: 422 }
        end
      end
    end

    private

    def quote_params
      params.require(:quote).permit(:shipping_method)
    end

  end
end