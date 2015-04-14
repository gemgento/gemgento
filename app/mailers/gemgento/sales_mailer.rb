module Gemgento
  class SalesMailer < ActionMailer::Base
    default from: 'sales@gemgento.com'

    def order_email(order, email, name)
      @order = order
      mail(to: "\"#{name}\" <#{email}>", subject: order_subject)
    end

    def invoice_email(order, email, name)
      @order = order
      mail(to: "\"#{name}\" <#{email}>", subject: invoice_subject)
    end

    def shipment_email(order, email, name)
      @order = order
      mail(to: "\"#{name}\" <#{email}>", subject: shipment_subject)
    end

    def credit_memo_email(order, email, name)
      @order = order
      mail(to: "\"#{name}\" <#{email}>", subject: credit_memo_subject)
    end

    protected

    def order_subject
      "Confirmation for Order #{@order.increment_id}"
    end

    def invoice_subject
      "Invoice for Order #{@order.increment_id}"
    end

    def shipment_subject
      "Shipment for Order #{@order.increment_id}"
    end

    def credit_memo_subject
      "Credit Memo for Order #{@order.increment_id}"
    end

  end
end