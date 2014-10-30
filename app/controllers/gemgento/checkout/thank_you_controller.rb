module Gemgento
  class Checkout::ThankYouController < CheckoutController
    skip_before_filter :validate_line_item_count
    skip_before_filter :validate_quote_user

    respond_to :json, :html

    def show
      if cookies[:order]
        @order = Order.find(session[:order])
        session.delete :order
        create_new_quote

        respond_with @order
      else
        redirect_to '/'
      end
    end
  end
end