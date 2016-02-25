module Gemgento
  class Checkout::PaypalController < CheckoutController
    skip_before_filter :set_quote
    skip_before_filter :validate_item_quantity
    skip_before_filter :validate_quote_user

    respond_to :json, :html

    def update

      if session[:quote]
        @quote = Quote.find(session[:quote])
        @quote.order_increment_id = params[:increment_id]
        @quote.mark_converted!
        redirect_to checkout_thank_you_path

      else
        redirect_to '/'
      end
    end

  end
end
