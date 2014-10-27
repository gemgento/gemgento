module Gemgento
  class Checkout::GiftController < CheckoutController
    skip_before_filter :validate_order_user

    respond_to :json, :html

    def update
      @order.gift_message = params[:order][:gift_message]
      @order.save

      respond_to do |format|
        format.html { redirect_to checkout_login_path }
        format.json { render json: { result: true, order: @order } }
      end
    end
  end
end