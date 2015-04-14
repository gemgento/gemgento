module Gemgento
  module Magento
    module Email
      module Sales
        class InvoicesController < Gemgento::Magento::BaseController

          def create
            Gemgento::SalesMailer.invoice_email(
                params[:data][:recipients],
                params[:data][:sender],
                params[:data][:order],
                params[:data][:invoice]
            )
            render nothing: true
          end

        end
      end
    end
  end
end