module Gemgento
  class SalesMailer < ActionMailer::Base
    default from: 'sales@gemgento.com'

    def order_email(recipients, from, order_source)
      @order = Gemgento::Order.find_by(magento_id: order_source[:entity_id])
      @order_source = order_source

      mail(
          to: recipients[:to],
          cc: recipients[:cc],
          bcc: recipients[:bcc],
          from: from,
          subject: "Confirmation for Order #{@order.increment_id}"
      ).deliver
    end

    def invoice_email(recipients, from, order_source, invoice_source)
      @order = Gemgento::Order.find_by(magento_id: order_source[:entity_id])
      @order_source = order_source
      @invoice_source = invoice_source

      mail(
          to: recipients[:to],
          cc: recipients[:cc],
          bcc: recipients[:bcc],
          from: from,
          subject: "Invoice for Order #{@order.increment_id}"
      ).deliver
    end

    def shipment_email(recipients, from, order_source, shipment_source)
      @order = Gemgento::Order.find_by(magento_id: order_source[:entity_id])
      @order_source = order_source
      @shipment_source = shipment_source

      mail(
          to: recipients[:to],
          cc: recipients[:cc],
          bcc: recipients[:bcc],
          from: from,
          subject: "Shipment for Order #{@order.increment_id}"
      ).deliver
    end

    def credit_memo_email(recipients, from, order_source, credit_memo_source)
      @order = Gemgento::Order.find_by(magento_id: order_source[:entity_id])
      @order_source = order_source
      @credit_memo_source = credit_memo_source

      mail(
          to: recipients[:to],
          cc: recipients[:cc],
          bcc: recipients[:bcc],
          from: from,
          subject: "Credit Memo for Order #{@order.increment_id}"
      ).deliver
    end

  end
end