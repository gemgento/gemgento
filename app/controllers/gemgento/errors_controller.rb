module Gemgento
  class ErrorsController < BaseController
    def generic
      raise '500 generic error' 
    end
  end
end