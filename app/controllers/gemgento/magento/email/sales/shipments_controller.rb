module Gemgento
  module Magento
    module Email
      module Sales
        class ShipmentsController < Gemgento::Magento::BaseController

          def create
            order = Gemgento::API::SOAP::Sales::Order.fetch(params[:data][:order][:increment_id])
            shipment = Gemgento::Magento::ShipmentAdapter.find(params[:data][:shipment][:increment_id]).import

            Gemgento::SalesMailer.shipment_email(
                params[:data][:recipients],
                params[:data][:sender],
                order,
                shipment
            ).deliver

            render nothing: true
          end

        end
      end
    end
  end
end