module Gemgento
  module Magento
    class OrdersController < Gemgento::Magento::BaseController

      def update
        @order = Gemgento::Magento::OrderAdapter.find(params[:data][:increment_id]).import
        render nothing: true
      end

    end
  end
end