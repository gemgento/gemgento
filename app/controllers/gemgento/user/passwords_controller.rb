module Gemgento
  class User::PasswordsController < Devise::PasswordsController
    include SslRequirement

    ssl_required :new, :create, :edit, :update
  end
end