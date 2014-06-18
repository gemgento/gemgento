module Gemgento
  class Checkout::CouponsController < Checkout::CheckoutBaseController
    respond_to :json

    def create
      if current_order.apply_coupon(params[:code])
        set_totals
        response = {
            result: true,
            order: current_order,
        }
        response = merge_totals(response)
      else
        response =  {
            result: false,
            order: current_order,
            errors: 'Code is not valid'
        }
      end

      render json: response
    end

    def destroy
      if current_order.remove_coupons
        set_totals
        response = {
            result: true,
            order: current_order,
        }
        response = merge_totals(response)
      else
        response =  {
            result: false,
            order: current_order,
            errors: 'Problem remove coupons from order'
        }
      end

      render json: response
    end

  end
end