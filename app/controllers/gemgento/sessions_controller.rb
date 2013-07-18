module Gemgento
  class SessionsController < Devise::SessionsController
    layout 'application'

    def create
      super
      @login_resource = resource
    end

  end
end
