module Gemgento
  class Checkout::GiftController < CheckoutController
    skip_before_filter :validate_order_user

    respond_to :json, :html

    def update
      current_order.gift_message = params[:order][:gift_message]
      current_order.save

      respond_to do |format|
        format.html { redirect_to checkout_login_path }
        format.json { render json: { result: true, order: current_order } }
      end
    end
  end
end