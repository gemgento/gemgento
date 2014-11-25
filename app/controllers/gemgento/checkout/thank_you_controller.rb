module Gemgento
  class Checkout::ThankYouController < CheckoutController
    skip_before_filter :validate_item_quantity
    skip_before_filter :validate_quote_user
    skip_before_filter :set_quote

    respond_to :json, :html

    def show
      if session[:quote]
        @quote = Quote.find(session[:quote])
        @order = @quote.order
        create_new_quote

        respond_with @order
      else
        redirect_to '/'
      end
    end
  end
end