module Gemgento
  class OrderMailer < ActionMailer::Base
    layout 'email'
    default css: 'email'

    def confirm_email(order, resend = false)
      @order = order
      @permalink = "/email/order-confirm/#{@order.magento_id}"

      to = @order.customer_email
      bcc = Config[:email][:bcc]

      env = Rails.env.production? ? '' : 'TEST: '
      subject = (resend ? "[#{t(:resend).upcase}] " : '')
      subject += "#{env} #{Config[:site][:name]} #{t('order_mailer.confirm_email.subject')} ##{order.magento_id}"

      mail(:to => to, :bcc => bcc, :subject => subject)
    end

    def cancel_email(order, resend = false)
      default_url_options[:host] = Config[:site][:url]

      @order = order
      @permalink = "/email/order-cancel/#{@order.magento_id}"

      unless Rails.env.production?
        to = Config[:email][:to]
      else
        to = @order.email
        to = @order.user.email if @order.user
      end
      bcc = Config[:email][:bcc]

      env = Rails.env.production? ? '' : 'TEST: '
      subject = (resend ? "[#{t(:resend).upcase}] " : '')
      subject += "#{env} #{Config[:site][:name]} #{t('order_mailer.cancel_email.subject')} ##{order.magento_id}"

      mail(:to => to, :bcc => bcc, :subject => subject)
    end
  end
end