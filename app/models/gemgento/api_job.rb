module Gemgento

  # @author Gemgento LLC
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
        transition from: 'ready', to: 'complete'
        transition from: 'error', to: 'complete'
      end
      event :error do
        transition from: 'active', to: 'error'
        transition from: 'ready', to: 'error'
      end

      before_transition to: 'ready', do: :is_ready!
      before_transition to: 'complete', do: :is_completed!
      after_transition to: 'error', do: :error!
      after_transition to: 'complete', do: :finalize!
    end

    # Determine if the ApiJob is ready to be activated. This method needs to be overridden in the child class.
    #
    # @return [void]
    def is_ready!
    end

    # Determine if the ApiJob is completed.  This method needs to be overridden in the child class.
    #
    # @return [void]
    def is_completed!
    end

    # Print the ApiJob details after the ApiJob has transitioned to the error state.
    #
    # @return [void]
    def error!
      puts(self.inspect)
    end

    # Lock the ApiJob after it has transitioned to the complete state.
    #
    # @return [void]
    def finalize!
      self.update_attribute('locked', true)
    end

    # Perform the ApiJob.  This is meant to be overridden in the child class.  The requirements of overriding this
    # method are to transition the ApiJob into the active state before doing anything, then upon completion, transition
    # to either the complete or error state.
    #
    # @return [void]
    def activate(payload)
      self.active
      # perform action here
      self.complete
    end

  end
end
