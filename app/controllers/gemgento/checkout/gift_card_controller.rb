module Gemgento
  class Checkout::GiftCardController < Checkout::CheckoutBaseController
    respond_to :json, :html

    def create
      result = current_order.apply_gift_card(params[:gift_card_code])

      respond_to do |format|
        if result == true
          format.html { redirect_to cart_path, notice: 'The Gift Card was successfully applied.' }
          format.json { render json: { result: true, order: current_order, totals: current_order.totals } }
        else
          format.html { redirect_to cart_path, alert: result }
          format.json { render json: { result: false, errors: result }, status: 422 }
        end
      end
    end

    def destroy
      result = current_order.remove_gift_card(params[:gift_card_code])

      if result == true
        format.html { redirect_to cart_path, notice: 'The Gift Card was removed from the order.' }
        format.json { render json: { result: true, order: current_order, totals: current_order.totals } }
      else
        format.html { redirect_to cart_path, alert: result }
        format.json { render json: { result: false, errors: result }, status: 422 }
      end
    end
  end
end