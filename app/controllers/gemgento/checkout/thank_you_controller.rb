module Gemgento
  class Checkout::ThankYouController < Checkout::CheckoutBaseController

    respond_to :json, :html

    def show
      @order = current_order
      create_new_cart

      respond_with @order
    end

  end
end