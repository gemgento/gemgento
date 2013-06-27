module Gemgento
  class OrderMailer < ActionMailer::Base
    layout 'email'

    default :from => Gemgento::Config[:email][:orders_from] || Gemgento::Config[:email][:default_from]

    def confirm_email(order, resend = false)
      @order = order
      @permalink = "/email/order-confirm/#{@order.magento_id}"

      to = @order.customer_email
      bcc = Gemgento::Config[:email][:bcc]

      env = Rails.env.production? ? '' : 'TEST: '
      subject = (resend ? "[#{t(:resend).upcase}] " : '')
      subject += "#{env} #{Gemgento::Config[:site][:name]} #{t('order_mailer.confirm_email.subject')} ##{order.magento_id}"

      mail(:to => to, :bcc => bcc, :subject => subject)
    end

    def cancel_email(order, resend = false)
      default_url_options[:host] = Gemgento::Config[:site][:url]

      @order = order
      @permalink = "/email/order-cancel/#{@order.magento_id}"

      unless Rails.env.production?
        to = Gemgento::Config[:email][:to]
      else
        to = @order.email
        to = @order.user.email if @order.user
      end
      bcc = Gemgento::Config[:email][:bcc]

      env = Rails.env.production? ? '' : 'TEST: '
      subject = (resend ? "[#{t(:resend).upcase}] " : '')
      subject += "#{env} #{Gemgento::Config[:site][:name]} #{t('order_mailer.cancel_email.subject')} ##{order.magento_id}"

      mail(:to => to, :bcc => bcc, :subject => subject)
    end
  end
end