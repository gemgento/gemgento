module Gemgento
  class Checkout::GiftCardController < CheckoutController
    skip_before_filter :validate_quote_user

    respond_to :json, :html

    def create
      result = @quote.apply_gift_card(params[:gift_card_code])

      respond_to do |format|
        if result == true
          format.html { redirect_to :back, notice: 'The Gift Card was successfully applied.' }
          format.json { render json: { result: true, order: @quote, totals: @quote.totals } }
        else
          format.html { redirect_to :back, alert: @quote.errors[:base].to_sentence }
          format.json { render json: { result: false, errors: @quote.errors[:base] }, status: 422 }
        end
      end

    rescue ActionController::RedirectBackError
      redirect_to cart_path
    end

    def destroy
      result = @quote.remove_gift_card(params[:gift_card_code])

      if result == true
        format.html { redirect_to :back, notice: 'The Gift Card was removed from the order.' }
        format.json { render json: { result: true, order: @quote, totals: @quote.totals } }
      else
        format.html { redirect_to :back, alert: @quote.errors[:base].to_sentence }
        format.json { render json: { result: false, errors: @quote.errors[:base] }, status: 422 }
      end

    rescue ActionController::RedirectBackError
      redirect_to cart_path
    end
  end
end