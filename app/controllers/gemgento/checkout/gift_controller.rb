module Gemgento
  class Checkout::GiftController < Checkout::CheckoutBaseController
    respond_to :json, :html

    def update
      current_order.gift_message = params[:order][:gift_message]
      # @order.status.sync_needed = false
      current_order.save

      puts "current_order.gift_message ====>>>> #{current_order.gift_message}"

      respond_to do |format|
        format.html { render '/checkout/signin' }        
        format.json { render json: { result: true, order: current_order } }
      end
    end
  end
end