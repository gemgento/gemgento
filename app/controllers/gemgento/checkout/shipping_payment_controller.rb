module Gemgento
  class Checkout::ShippingPaymentController < CheckoutController
    respond_to :json, :html

    def show
      initialize_shipping_variables
      initialize_payment_variables

      respond_to do |format|
        format.html
        format.json { render json: {
            shipping_methods: @shipping_methods,
            payment_methods: @payment_methods,
            saved_credit_cards: @saved_credit_cards,
            totals: @order.totals
        } }
      end
    end

    def update
      @payment = @order.payment.nil? ? Payment.new : @order.payment
      @payment.attributes = payment_params

      respond_to do |format|

        if @order.set_shipping_method(params[:shipping_method], JSON.parse(cookies[:shipping_methods]))

          if @payment.valid? && @order.set_payment(payment_params)
            session[:payment_data] = payment_params

            format.html { redirect_to checkout_confirm_path }
            format.json { render json: { result: true, order: @order } }
          else
            initialize_shipping_variables
            initialize_payment_variables

            flash[:error] = 'Invalid payment information. Please review all details and try again.'
            format.html { render action: :show }
            format.json do
              render json: {
                  result: false,
                  errors: @payment.errors.any? ? @payment.errors.full_messages : 'Invalid payment information. Please review all details and try again.'
              }
            end
          end
        else
          initialize_shipping_variables
          initialize_payment_variables

          flash[:error] = 'Please select a shipping method'
          format.html { render action: :show }
          format.json { render json: { result: false, errors: 'Please select a shipping method' } }
        end
      end
    end
  end
end