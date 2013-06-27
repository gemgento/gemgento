module Sellect
  class AlertMailer < ActionMailer::Base
    helper Sellect::BaseHelper

    layout 'email'

    default :from => Sellect::Config[:email][:default_from]

    def alert_challenged_payment(order, resend = false)
      default_url_options[:host] = Sellect::Config[:site][:url]

      @order = order

      env = Rails.env.production? ? '' : 'TEST: '
      subject = (resend ? "[#{t(:resend).upcase}] " : '')
      subject += "#{env} #{Sellect::Config[:site][:name]} #{t('alert_mailer.challenged_payment.subject')} for Order ##{@order.number}"

      to = Sellect::Config[:email][:payment_alert_to]
      bcc = Sellect::Config[:email][:payment_alert_bcc]
      mail(:to => to, :bcc => bcc, :subject => subject)
    end

    def alert_api_job_error(api_job, resend = false)
      default_url_options[:host] = Sellect::Config[:site][:url]

      @api_job = api_job

      env = Rails.env.production? ? '' : 'TEST: '
      subject = (resend ? "[#{t(:resend).upcase}] " : '')
      subject += "#{env} #{Sellect::Config[:site][:name]} #{t('alert_mailer.api_job_error.subject')} for ##{@api_job.type}"

      to = Sellect::Config[:email][:api_job_alert_to]
      bcc = Sellect::Config[:email][:api_job_alert_bcc]
      mail(:to => to, :bcc => bcc, :subject => subject)
    end
  end
end