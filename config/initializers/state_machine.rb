module StateMachine
  module Integrations
    module ActiveModel
      public :around_validation # fix for rails 4.1 issue
    end
  end
end