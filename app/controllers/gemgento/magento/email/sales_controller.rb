module Gemgento
  module Magento
    module Email
      class SalesController < Gemgento::Magento::EmailsController

        def create
          @order = Gemgento::Order.find_by(magento_id: params[:data][:order_id])
          Gemgento::SalesMailer.order_email(@order, params[:data][:email], params[:data][:name]).deliver
          render nothing: true
        end

      end
    end
  end
end