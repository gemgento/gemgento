module Gemgento
  class Checkout::GiftController < CheckoutController
    skip_before_filter :validate_quote_user

    def update
      respond_to do |format|

        if @quote.update(quote_params)
          format.html { redirect_to after_gift_update_success_path }
          format.json { render json: { result: true } }
        else
          format.html { redirect_to after_gift_update_fail_path, alert: 'There was a problem saving the gift message.' }
          format.json { render json: { result: false, errors: @quote.errors.full_messages }, status: 422 }
        end
      end
    end

    private

    def after_gift_update_success_path
      checkout_login_path
    end

    def after_gift_update_fail_path
      cart_path
    end

    def quote_params
      params.require(:quote).permit(:gift_message)
    end
  end
end