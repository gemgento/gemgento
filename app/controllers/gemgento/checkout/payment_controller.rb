module Gemgento
  class Checkout::PaymentController < CheckoutController
    before_filter :auth_order_user

    respond_to :json, :html

    def show
      initialize_payment_variables

      respond_to do |format|
        format.html
        format.json { render json: {
            payment_methods: @payment_methods,
            saved_credit_cards: @saved_credit_cards,
            totals: current_order.totals
        } }
      end
    end

    def update
      @order_payment = current_order.order_payment.nil? ? Gemgento::OrderPayment.new : current_order.order_payment
      @order_payment.attributes = order_payment_params

      respond_to do |format|
        if @order_payment.valid? && current_order.set_payment(order_payment_params)
          session[:payment_data] = order_payment_params

          format.html { render checkout_confirm_path }
          format.json { render json: { result: true, order: current_order } }
        else
          initialize_payment_variables
          format.html { render action: :show, alert: 'Invalid payment information. Please review all details and try again.' }
          format.json { render json: {
              result: false,
              errors: current_order.order_payment.errors.any? ? current_order.order_payment.errors.full_messages : 'Invalid payment information. Please review all details and try again.'
          } }
        end
      end
    end

  end
end
