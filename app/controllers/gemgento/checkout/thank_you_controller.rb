module Gemgento
  class Checkout::ThankYouController < CheckoutController
    skip_before_filter :set_quote
    skip_before_filter :validate_item_quantity
    skip_before_filter :validate_quote_user

    before_action :set_quote

    respond_to :json, :html

    def show
      @order = @quote.order

      # create a new quote
      session.delete :quote
      @current_quote = Quote.current(current_store, nil, current_user)

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

  end
end