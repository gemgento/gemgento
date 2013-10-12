module Gemgento
  class Checkout::ThankYouController < Checkout::CheckoutBaseController

    def show
      create_new_cart

      render :layout => false if request.headers['X-PJAX']
    end

  end
end