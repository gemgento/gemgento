module Gemgento
  module Magento
    module Email
      module Sales
        class CreditMemosController < Gemgento::Magento::BaseController

          def create
            Gemgento::SalesMailer.credit_memo_email(
                params[:data][:recipients],
                params[:data][:sender],
                params[:data][:order],
                params[:data][:credit_memo]
            ).deliver
            render nothing: true
          end

        end
      end
    end
  end
end