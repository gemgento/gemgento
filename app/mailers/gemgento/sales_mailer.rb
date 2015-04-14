module Gemgento
  class SalesMailer < ActionMailer::Base
    default from: 'sales@gemgento.com'

    def order_email(order, email, name)
      @order = order
      mail(to: "\"#{name}\" <#{email}>", subject: "Confirmation for Order #{@order.increment_id}")
    end

    def invoice_email(order, email, name)
      @order = order
      mail(to: "\"#{name}\" <#{email}>", subject: "Invoice for Order #{@order.increment_id}")
    end

    def shipment_email(order, email, name)
      @order = order
      mail(to: "\"#{name}\" <#{email}>", subject: "Shipment for Order #{@order.increment_id}")
    end

    def credit_memo_email(order, email, name)
      @order = order
      mail(to: "\"#{name}\" <#{email}>", subject: "Credit Memo for Order #{@order.increment_id}")
    end

  end
end