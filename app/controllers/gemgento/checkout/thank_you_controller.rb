module Gemgento
  class Checkout::ThankYouController < Checkout::CheckoutBaseController

    def show
      create_new_cart
    end

  end
end