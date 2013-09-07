module Gemgento
  class Users::PasswordsController < Devise::PasswordsController
    ssl_required :new, :create, :edit, :update
  end
end