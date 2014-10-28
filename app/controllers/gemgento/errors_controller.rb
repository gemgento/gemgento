module Gemgento
  class ErrorsController < ApplicationController
    def generic
      raise '500 generic error' 
    end
  end
end