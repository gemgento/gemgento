module Gemgento
  class Checkout::PaymentController < CheckoutController
    respond_to :json, :html

    def show
      initialize_payment_variables

      respond_to do |format|
        format.html
        format.json { render json: {
            quote: @quote,
            payment_methods:(@payment_methods || nil),
            saved_credit_cards: @saved_credit_cards,
            totals: @quote.totals
        } }
      end
    end

    def update
      @quote.push_payment_method = true

      respond_to do |format|
        if @quote.update(quote_params)
          session[:payment_data] = quote_params[:payment_attributes]
          format.html { render checkout_confirm_path }
          format.json { render json: { result: true, quote: @quote } }
        else
          initialize_payment_variables
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @quote.errors.full_messages}, status: 422 }
        end
      end
    end

    private

    def quote_params
      params.require(:quote).permit(payment_attributes: [:id, :method, :cc_cid, :cc_number, :cc_type, :cc_exp_year, :cc_exp_month, :cc_owner, :save_card, :payment_id])
    end

  end
end
