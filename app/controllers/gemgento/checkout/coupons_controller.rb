module Gemgento
  class Checkout::CouponsController < CheckoutController
    skip_before_filter :validate_order_user

    respond_to :json, :html

    def create
      result = @order.apply_coupon(params[:code])

      respond_to do |format|
        if result == true
          format.html { redirect_to cart_path, notice: 'The coupon was successfully applied.' }
          format.json { render json: { result: true, order: @order, totals: @order.totals } }
        else
          format.html { redirect_to cart_path, alert: result }
          format.json { render json: { result: false, errors: result }, status: 422 }
        end
      end
    end

    def destroy
      result = @order.remove_coupons

      respond_to do |format|
        if result == true
          format.html { redirect_to cart_path, notice: 'The coupons have been removed.' }
          format.json { render json: { result: true, order: @order, totals: @order.totals } }
        else
          format.html { redirect_to cart_path, alert: result }
          format.json { render json: { result: false, errors: result }, status: 422 }
        end
      end
    end

  end
end