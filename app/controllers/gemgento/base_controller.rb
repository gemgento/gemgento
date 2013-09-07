module Gemgento
  class BaseController < ActionController::Base
    include SslRequirement
  end
end

