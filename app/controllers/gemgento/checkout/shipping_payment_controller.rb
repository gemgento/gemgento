module Gemgento
  class Checkout::ShippingPaymentController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user
    before_filter :set_totals, only: :show

    respond_to :json, :html

    def show
      initialize_shipping_variables
      initialize_payment_variables

      respond_to do |format|
        format.html

        response = {
            shipping_methods: @shipping_methods,
            payment_methods: @payment_methods,
            saved_credit_cards: @saved_credit_cards
        }
        response = merge_totals(response)

        format.json do
          render json: response
        end
      end
    end

    def update
      @order_payment = current_order.order_payment.nil? ? Gemgento::OrderPayment.new : current_order.order_payment
      @order_payment.attributes = order_payment_params

      respond_to do |format|

        if current_order.set_shipping_method(params[:shipping_method], JSON.parse(cookies[:shipping_methods]))

          if @order_payment.valid? && current_order.set_payment(order_payment_params)
            session[:payment_data] = order_payment_params

            format.html { redirect_to checkout_confirm_path }
            format.json { render json: { result: true, order: current_order } }
          else
            initialize_shipping_variables
            initialize_payment_variables

            flash[:error] = 'Invalid payment information. Please review all details and try again.'
            format.html { render action: :show }
            format.json do
              render json: {
                  result: false,
                  errors: @order_payment.errors.any? ? @order_payment.errors.full_messages : 'Invalid payment information. Please review all details and try again.'
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