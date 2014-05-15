module Gemgento
  class ErrorsController < Gemgento::ApplicationController
    def generic
      raise '500 generic error' 
    end
  end
end