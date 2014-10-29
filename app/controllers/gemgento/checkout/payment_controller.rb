module Gemgento
  class Checkout::PaymentController < CheckoutController
    respond_to :json, :html

    def show
      initialize_payment_variables

      respond_to do |format|
        format.html
        format.json { render json: {
            payment_methods: @payment_methods,
            saved_credit_cards: @saved_credit_cards,
            totals: @quote.totals
        } }
      end
    end

    def update
      @payment = @quote.payment.nil? ? Payment.new : @quote.payment
      @payment.attributes = payment_params

      respond_to do |format|
        if @payment.valid? && @quote.set_payment(payment_params)
          session[:payment_data] = payment_params

          format.html { render checkout_confirm_path }
          format.json { render json: { result: true, order: @quote } }
        else
          initialize_payment_variables
          format.html { render action: :show, alert: 'Invalid payment information. Please review all details and try again.' }
          format.json { render json: {
              result: false,
              errors: @quote.payment.errors.any? ? @quote.payment.errors.full_messages : 'Invalid payment information. Please review all details and try again.'
          } }
        end
      end
    end

  end
end
