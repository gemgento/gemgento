module Gemgento
  class Checkout::GiftController < CheckoutController
    skip_before_filter :validate_quote_user

    def update
      respond_to do |format|

        if @quote.update(quote_params)
          format.html { redirect_to checkout_login_path }
          format.json { render json: { result: true, order: @quote } }
        else
          format.html { redirect_to cart_path, alert: 'There was a problem saving the gift message.' }
          format.json { render json: { result: false, errors: @quote.errors.full_messages } }
        end
      end
    end

    private

    def quote_params
      params.require(:quote).permit(:gift_message)
    end
  end
end