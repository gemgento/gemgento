module Gemgento
  class Checkout::ShippingPaymentController < CheckoutController
    respond_to :json, :html

    def show
      initialize_shipping_variables
      initialize_payment_variables

      respond_to do |format|
        format.html
        format.json { render json: {
            quote: @quote,
            shipping_methods: @shipping_methods,
            payment_methods: (@payment_methods || nil),
            saved_credit_cards: @saved_credit_cards,
            totals: @quote.totals
        } }
      end
    end

    def update
      @quote.shipping_amount = @quote.get_shipping_amount(quote_params[:shipping_method], JSON.parse(cookies[:shipping_methods], symbolize_names: true))
      @quote.push_shipping_method = true
      @quote.push_payment_method = true

      respond_to do |format|

        if @quote.update(quote_params)
          session[:payment_data] = quote_params[:payment_attributes]

          if !@quote.payment.is_redirecting_payment_method?('payment_after')
            format.html { redirect_to checkout_confirm_path }
            format.json { render json: { result: true, order: @quote, totals: @quote.totals } }
          else
            format.html { redirect_to payment_after_redirect_url }
            format.json { render json: { result: true, payment_redirect_url: payment_after_redirect_url } }
          end

        else
          initialize_shipping_variables
          initialize_payment_variables
          format.html { render action: :show }
          format.json { render json: { result: false, errors: @quote.errors }, status: 422 }
        end
      end
    end

    private

    def quote_params
      params.require(:quote).permit(
          :shipping_method,
          payment_attributes: [:id, :method, :cc_cid, :cc_number, :cc_type, :cc_exp_year, :cc_exp_month, :cc_owner, :save_card, :payment_id]
      )
    end

  end
end