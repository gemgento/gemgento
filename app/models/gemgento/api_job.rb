module Gemgento
  class ApiJob < ActiveRecord::Base
    belongs_to :source, polymorphic: true

    state_machine :state, initial: 'pending', use_transactions: false do
      event :ready do
        transition from: 'pending', to: 'ready'
      end
      event :active do
        transition from: 'ready', to: 'active'
      end
      event :complete do
        transition from: 'active', to: 'complete'
        transition from: 'error', to: 'complete'
      end
      event :error do
        transition from: 'ready', to: 'error'
      end

      before_transition to: 'ready', do: :is_ready!
      before_transition to: 'complete', do: :is_completed!
      after_transition to: 'error', do: :error!
      after_transition to: 'complete', do: :finalize!
    end

    def is_ready!
    end

    def is_completed!
    end

    def error!
      puts(self.inspect)
    end

    def finalize!
      self.update_attribute('locked', true)
    end

    def activate(payload)
      self.active
      # perform action here
      self.complete
    end

  end
end
