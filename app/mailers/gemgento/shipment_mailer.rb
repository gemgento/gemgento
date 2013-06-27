module Sellect
  class ShipmentMailer < ActionMailer::Base
    helper Sellect::BaseHelper

    layout 'email'

    default :from => Sellect::Config[:email][:default_from]

    def shipped_email(shipment, resend = false)
      default_url_options[:host] = Sellect::Config[:site][:url]

      @order = shipment.order
      @permalink = "/email/track/#{@order.number}"

      to = @order.email
      to = @order.user.email if @order.user
      bcc = Sellect::Config[:email][:bcc]

      env = Rails.env.production? ? "" : "TEST: "
      subject = (resend ? "[#{t(:resend).upcase}] " : '')
      subject += "#{env} #{Sellect::Config[:site][:name]} Track ##{@order.number}"

      mail(:to => to, :bcc => bcc, :subject => subject)
    end
  end
end