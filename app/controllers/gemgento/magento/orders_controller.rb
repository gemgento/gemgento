module Gemgento
  module Magento
    class OrdersController < Gemgento::Magento::BaseController

      def update
        @order = Gemgento::API::SOAP::Sales::Order.fetch(params[:data][:increment_id])
        render nothing: true
      end

    end
  end
end