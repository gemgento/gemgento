module Gemgento
  class Users::PasswordsController < Devise::PasswordsController
    include SslRequirement

    ssl_required :new, :create, :edit, :update
  end
end