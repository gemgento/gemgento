module Sellect
  class SubscriberMailer < ActionMailer::Base

    def confirm_email(subscriber)
      @subscriber = subscriber
      subject = "Subscription Confirmation"
      mail(:to => @subscriber.email, :subject => "Subscription Confirmation")
    end

  end
end
