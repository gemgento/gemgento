module Gemgento
  class Checkout::ThankYouController < CheckoutController
    skip_before_filter :set_quote
    skip_before_filter :validate_item_quantity
    skip_before_filter :validate_quote_user

    before_action :set_quote
    before_action :redirect_paypal

    respond_to :json, :html

    def show
      @order = @quote.order
      create_new_quote

      respond_with @order
    end

    private

    def set_quote
      if session[:quote]
        @quote = Quote.find(session[:quote])
      else
        redirect_to '/'
      end
    end

    def redirect_paypal
      if @quote.order.nil? && params[:paypal]
        @quote.mark_converted!(params[:paypal])
        redirect_to checkout_thank_you_path
      end
    end

  end
end