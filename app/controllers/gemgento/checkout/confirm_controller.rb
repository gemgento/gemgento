module Gemgento
  class Checkout::ConfirmController < CheckoutController
    respond_to :json, :html

    def show
      set_order_component_vars

      respond_to do |format|
        format.html
        format.json { render json: { order: @quote, shipping_method: @shipping_method, totals: @quote.totals } }
      end
    end

    def update
      @quote.payment.update(session[:payment_data])

      respond_to do |format|
        if @quote.process(request.remote_ip)
          session.delete :payment_data

          format.json { render json: { result: true, order: @quote } }
          format.html do
            cookies[:order] = @quote.order.id
            redirect_to checkout_thank_you_path
          end
        else
          format.html do
            set_order_component_vars
            render 'show'
          end
          format.json { render json: { result: false, errors: @quote.errors.full_messages }, status: 422 }
        end
      end

    end

    private

    def set_order_component_vars
      @shipping_address = @quote.shipping_address
      @billing_address = @quote.billing_address
      @payment = @quote.payment

      @shipping_method = get_magento_shipping_method
    end

  end
end