module Sellect
  class RefundMailer < ActionMailer::Base
    helper Sellect::BaseHelper

    layout 'email'

    default :from => Sellect::Config[:email][:default_from]

    def refund_email(refund, resend = false)
      default_url_options[:host] = Sellect::Config[:site][:url]

      @refund = refund
      @order = refund.order

      to = @order.email
      to = @order.user.email if @order.user
      bcc = Sellect::Config[:email][:bcc]

      env = Rails.env.production? ? "" : "TEST: "
      subject = "#{env} #{Sellect::Config[:site][:name]} #{t('refund_mailer.refund_email.subject')} ##{@order.number}"

      mail(:to => to, :bcc => bcc, :subject => subject)
    end
  end
end