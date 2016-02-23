module Gemgento
  class ImportJob < ActiveJob::Base

    # Run import process
    #
    # @param import [Gemgento::Import]
    def perform(import)
      import.process
    end

  end
end