module Gemgento
  class Checkout::CouponsController < CheckoutController
    skip_before_filter :validate_quote_user

    respond_to :json, :html

    def create
      result = @quote.apply_coupon(params[:code])

      respond_to do |format|
        if result == true
          format.html { redirect_to :back, notice: 'The coupon was successfully applied.' }
          format.json { render json: { result: true, order: @quote, totals: @quote.totals } }
        else
          format.html { redirect_to :back, alert: @quote.errors[:base].to_sentence }
          format.json { render json: { result: false, errors: @quote.errors.full_messages }, status: 422 }
        end
      end

    rescue ActionController::RedirectBackError
      redirect_to cart_path
    end

    def destroy
      result = @quote.remove_coupons

      respond_to do |format|
        if result == true
          format.html { redirect_to :back, notice: 'The coupons have been removed.' }
          format.json { render json: { result: true, order: @quote, totals: @quote.totals } }
        else
          format.html { redirect_to :back, alert: @quote.errors[:base].to_sentence }
          format.json { render json: { result: false, errors: @quote.errors.full_messages }, status: 422 }
        end
      end

    rescue ActionController::RedirectBackError
      redirect_to cart_path
    end

  end
end