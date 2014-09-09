module Gemgento
  class StockNotificationsController < ApplicationController
    respond_to :json

    def create
      @stock_notification = StockNotification.create(stock_notification_params)

      if @stock_notification.save
        render json: @stock_notification
      else
        render json: { errors: @stock_notification.errors }, status:  422
      end
    end

    private

    def stock_notification_params
      params.require(:stock_notification).permit(:id, :email, :name, :phone, :product_id, :product_name, :product_url)
    end

  end
end
