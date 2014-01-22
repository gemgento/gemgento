module Gemgento
  class Checkout::PaymentController < Checkout::CheckoutBaseController
    before_filter :auth_cart_contents
    before_filter :auth_order_user

    respond_to :json, :html

    def show
      set_totals
      @payment_methods = current_order.get_payment_methods

      @card_types = {
          'Credit card type' => nil,
          Visa: 'VI',
          MasterCard: 'MC',
          'American Express' => 'AE'
      }

      @exp_years = []
      Time.now.year.upto(Time.now.year + 10) do |year|
        @exp_years << year.to_s
      end

      @exp_months = {}
      1.upto(12) do |month|
        month_string = month.to_s.length == 1 ? "0#{month.to_s}" : month.to_s
        @exp_months[month] = month_string
      end

      current_order.order_payment = OrderPayment.new if current_order.order_payment.nil?

      respond_to do |format|
        format.html
        format.json do
          render json: {
              payment_methods: @payment_methods,
              card_types: @card_types,
              exp_years: @exp_years,
              exp_months: @exp_months,
              total: @total,
              tax: @tax,
              shipping: @shipping
          }
        end
      end
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
          format.html { redirect_to checkout_confirm_path }
          format.json { render json: { result: true, order: current_order } }
        else
          flash[:error] = 'Invalid payment information.  Please review all details and try again.'

          format.html { redirect_to checkout_payment_path }
          format.json do
            render json: {
                result: false,
                errors: 'Invalid payment information.  Please review all details and try again.'
            }
          end
        end
      end
    end

    private

    def order_payment_params
      params.require(:order).require(:order_payment_attributes).permit(:method, :cc_cid, :cc_number, :cc_type, :cc_exp_year, :cc_exp_month)
    end

  end
end