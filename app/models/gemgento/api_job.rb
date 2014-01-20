module Gemgento
  class ApiJob < ActiveRecord::Base
    attr_accessible :kind

    belongs_to :source, :polymorphic => true

    state_machine :initial => 'pending', :use_transactions => false do
      event :ready do
        transition :from => 'pending', :to => 'ready'
      end
      event :complete do
        transition :from => 'ready', :to => 'complete'
        transition :from => 'error', :to => 'complete'
      end
      event :error do
        transition :from => 'ready', :to => 'error'
      end

      before_transition :to => 'ready', :do => :is_ready!
      before_transition :to => 'complete', :do => :is_completed!
      after_transition :to => 'error', :do => :error!
      after_transition :to => 'complete', :do => :finalize!
    end

    def is_ready!
    end

    def is_completed!
    end

    def error!
      Sellect::AlertMailer.alert_api_job_error(self).deliver
    end

    def finalize!
      self.update_attribute('locked', true)
    end

    def activate(payload)
      self.complete
    end

  end
end
