module Gemgento
  module Magento
    module Email
      module Sales
        class ShipmentsController < Gemgento::Magento::BaseController

          def create
            Gemgento::SalesMailer.shipment_email(
                params[:data][:recipients],
                params[:data][:sender],
                params[:data][:order],
                params[:data][:shipment],
                params[:data][:tracks]
            ).deliver
            render nothing: true
          end

        end
      end
    end
  end
end