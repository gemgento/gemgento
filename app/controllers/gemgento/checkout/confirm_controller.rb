module Gemgento
  class Checkout::ConfirmController < CheckoutController
    respond_to :json, :html

    before_action :confirm_before_redirect, only: :update

    def show
      @quote.payment.assign_attributes(session[:payment_data]) if @quote.payment && session[:payment_data]
      @shipping_method = get_magento_shipping_method

      respond_to do |format|
        format.html
        format.json { render json: { order: @quote, shipping_method: @shipping_method, totals: @quote.totals } }
      end
    end

    def update
      @quote.payment.update(session[:payment_data]) if @quote.payment && session[:payment_data]

      respond_to do |format|
        if @quote.convert(request.remote_ip)
          session[:order_increment_id] = @quote.order_increment_id
          session.delete :payment_data

          if !@quote.payment.is_redirecting_payment_method?('confirm_after')
            format.html { redirect_to checkout_thank_you_path }
            format.json { render json: { result: true, order: @quote.order } }

          else
            format.html { redirect_to confirm_after_redirect_url }
            format.json { render json: { result: true, payment_redirect_url: confirm_after_redirect_url } }
          end
        else
          @shipping_method = get_magento_shipping_method
          format.html { render 'show' }
          format.json { render json: { result: false, errors: @quote.errors }, status: 422 }
        end
      end

    end

    private

    def confirm_before_redirect
      if @quote.payment && @quote.payment.is_redirecting_payment_method?('confirm_before')
        respond_to do |format|
          format.html { redirect_to confirm_before_redirect_url }
          format.json { render json: { result: true, payment_redirect_url: confirm_before_redirect_url } }
        end
      end
    end

    def confirm_before_redirect_url
      case @quote.payment.method
        when 'paypal_express'
          "#{Gemgento::Config[:magento][:url]}/paypal/express/placeOrder"
        else
          checkout_confirm_path
      end
    end

    def confirm_after_redirect_url
      case @quote.payment.method
        when 'paypal_standard'
          "#{Gemgento::Config[:magento][:url]}/paypal/standard/redirect?quote_id=#{@quote.magento_id}&store_id=#{@quote.store.magento_id}"
        else
          checkout_confirm_path
      end
    end

  end
end