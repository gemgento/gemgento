module Gemgento
  class Checkout::ThankYouController < CheckoutController
    respond_to :json, :html

    def show
      if cookies[:order]
        @order = Gemgento::Order.find(cookies[:order])
        cookies.delete :order
        create_new_cart

        respond_with @order
      else
        redirect_to '/'
      end
    end
  end
end