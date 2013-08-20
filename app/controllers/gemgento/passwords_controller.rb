module Gemgento
  class PasswordsController < Devise::PasswordsController

    # GET /resource/password/new
    def new
      self.resource = resource_class.new

      render 'gemgento/users/passwords/new'
    end

  end
end