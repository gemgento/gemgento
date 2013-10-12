module Gemgento
  class Checkout::PaymentController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user

    def show
      set_totals
      #@payment_methods = current_order.get_payment_methods

      @card_types = {
          'Credit card type' => nil,
          Visa: 'VI',
          MasterCard: 'MC',
          'American Express' => 'AE'
      }

      @exp_years = []
      Time.now.year.upto(Time.now.year + 10) do |year|
        @exp_years << year
      end

      @exp_months = []
      1.upto(12) do |month|
        @exp_months << month
      end

      current_order.order_payment = OrderPayment.new if current_order.order_payment.nil?

      render :layout => false if request.headers['X-PJAX']
    end

    def update
      if current_order.order_payment.nil?
        current_order.order_payment = OrderPayment.new(order_payment_params)
      else
        current_order.order_payment.update_attributes(order_payment_params)
      end

      current_order.order_payment.cc_owner = "#{current_order.billing_address.fname} #{current_order.billing_address.lname}"
      current_order.order_payment.cc_last4 = current_order.order_payment.cc_number[-4..-1]
      current_order.order_payment.save


      respond_to do |format|
        if current_order.push_payment_method
          format.html { redirect_to checkout_confirmation_path }
          format.js { render '/gemgento/checkout/payment/success' }
        else
          format.html { redirect_to checkout_payment_path }
          format.js { render '/gemgento/checkout/payment/error' }
        end

      end
    end

    private

    def order_payment_params
      params.require(:order).require(:order_payment_attributes).permit(:method, :cc_cid, :cc_number, :cc_type, :cc_exp_year, :cc_exp_month)
    end

  end
end