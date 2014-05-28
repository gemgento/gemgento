module Gemgento
  class Checkout::PaymentController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user
    before_filter :set_totals, only: :show

    respond_to :json, :html

    def show
      current_order.order_payment = Gemgento::OrderPayment.new if current_order.order_payment.nil?
      @payment_methods = current_order.get_payment_methods

      unless current_order.customer_is_guest
        @saved_credit_cards = current_user.saved_credit_cards
      else
        @saved_credit_cards = []
      end

      respond_to do |format|
        format.html

        response = {
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
      respond_to do |format|
        if current_order.set_payment(order_payment_params)
          session[:payment_data] = order_payment_params

          format.html { redirect_to checkout_confirm_path }
          format.json { render json: { result: true, order: current_order } }
        else
          flash[:error] = 'Invalid payment information. Please review all details and try again.'

          format.html { redirect_to checkout_payment_path }
          format.json do
            render json: {
                result: false,
                errors: current_order.order_payment.errors.any? ? current_order.order_payment.errors.full_messages : 'Invalid payment information. Please review all details and try again.'
            }
          end
        end
      end
    end

  end
end
