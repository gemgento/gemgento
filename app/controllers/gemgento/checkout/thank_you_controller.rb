module Gemgento
  class Checkout::ThankYouController < Checkout::CheckoutBaseController

    def show
      @order = current_order
      create_new_cart
    end

  end
end