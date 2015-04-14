module Gemgento
  module Magento
    module Email
      module Sales
        class ShipmentsController < Gemgento::Magento::BaseController

          def create
            @order = Gemgento::Order.find_by(magento_id: params[:data][:order_id])
            Gemgento::SalesMailer.shipment_email(@order, params[:data][:email], params[:data][:name]).deliver
            render nothing: true
          end

        end
      end
    end
  end
end