module Gemgento
  class Users::RegistrationsController < Devise::RegistrationsController
    include SslRequirement

    ssl_required :new, :create, :edit, :update, :destroy, :cancel
  end
end
