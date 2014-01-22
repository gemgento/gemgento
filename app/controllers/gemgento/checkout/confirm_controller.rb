module Gemgento
  class Checkout::ConfirmController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user

    respond_to :json, :html

    def show
      set_totals
      @shipping_address = current_order.shipping_address
      @billing_address = current_order.billing_address
      @payment = current_order.order_payment
      @cc_types = Gemgento::OrderPayment.cc_types

      current_order.get_shipping_methods.each do |shipping_method|
        if shipping_method[:code] == current_order.shipping_method
          @shipping_method = shipping_method
          break
        end
      end

      respond_to do |format|
        format.html
        format.json do
          render json: {
              order: current_order,
              cc_types: Gemgento::OrderPayment.cc_types,
              total: @total,
              tax: @tax,
              shipping: @shipping
          }
        end
      end

    end

    def update
      current_order.enforce_cart_data
      @order = current_order

      respond_to do |format|
        if current_order.process
          @order.reload

          format.html { redirect_to checkout_thank_you_path }
          format.json { render json: { result: true, order: @order } }
        else
          flash[:error] =

          format.html { redirect_to checkout_confirm_path }
          format.json do
            render json: {
                result: false,
                errors: 'There was a problem processing your order.  Please review order details and try again.'
            }
          end
        end
      end

    end

  end
end