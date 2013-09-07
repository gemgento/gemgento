module Gemgento
  class Users::RegistrationsController < Devise::RegistrationsController
    ssl_required :new, :create, :edit, :update, :destroy, :cancel
  end
end
