module Gemgento
  module Magento
    module Email
      module Sales
        class OrdersController < Gemgento::Magento::BaseController

          def create
            Gemgento::SalesMailer.order_email(
                params[:data][:recipients],
                params[:data][:sender],
                params[:data][:order]
            ).deliver
            render nothing: true
          end

        end
      end
    end
  end
end