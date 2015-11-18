module Gemgento
  class Checkout::ShippingController < CheckoutController
    respond_to :json, :html

    before_action :redirect_to_payment_step, unless: -> { @quote.shipping_method_required? }

    def show
      initialize_shipping_variables

      respond_to do |format|
        format.html
        format.json { render json: { quote: @quote, shipping_methods: @shipping_methods, totals: @quote.totals } }
      end
    end

    def update
      @quote.shipping_amount = @quote.get_shipping_amount(quote_params[:shipping_method], JSON.parse(cookies[:shipping_methods], symbolize_names: true))
      @quote.push_shipping_method = true

      respond_to do |format|
        if @quote.update(quote_params)
          format.html { redirect_to checkout_payment_path }
          format.json { render json: { result: true, quote: @quote, totals: @quote.totals } }
        else
          initialize_shipping_variables
          format.html { render action: :show }
          format.json { render json: { result: false, errors: @quote.errors.full_messages }, status: 422 }
        end
      end
    end

    private

    def quote_params
      params.require(:quote).permit(:shipping_method)
    end

    def redirect_to_payment_step
      respond_to do |format|
        format.html { redirect_to checkout_payment_path }
        format.json { render json: { quote: @quote, shipping_methods: [], totals: @quote.totals } }
      end
    end

  end
end