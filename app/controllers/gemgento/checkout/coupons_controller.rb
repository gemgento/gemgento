module Gemgento
  class Checkout::CouponsController < Checkout::CheckoutBaseController
    respond_to :json, :html

    def create
      respond_to do |format|
        if current_order.apply_coupon(params[:code])
          format.json do
            set_totals
            response = {
                result: true,
                order: current_order,
            }
            render json: merge_totals(response)
          end
        else
          format.json do
            render json: {
                result: false,
                order: current_order,
                errors: 'Code is not valid'
            }
          end
        end

        format.html do
          redirect_to :back
        end
      end
    end

    def destroy
      respond_to do |format|
        if current_order.remove_coupons
          format.json do
            set_totals
            response = {
                result: true,
                order: current_order,
            }
            render json: merge_totals(response)
          end
        else
          format.json do
            render json: {
                result: false,
                order: current_order,
                errors: 'Problem removing coupons from order'
            }
          end
        end

        format.html do
          redirect_to :back
        end
      end

    end
  end
end