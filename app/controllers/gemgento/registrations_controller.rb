module Gemgento
  class RegistrationsController < Devise::RegistrationsController
    layout 'application'

    def create
      key = params[key].nil? ? :checkout : :user

      @user = User.new
      @user.fname = params[key][:fname]
      @user.lname = params[key][:lname]
      @user.email = params[key][:email]
      @user.store = Gemgento::Store.first
      @user.user_group = Gemgento::UserGroup.find_by(code: 'General')
      @user.magento_password = params[key][:password]
      @user.password = params[key][:password]
      @user.password_confirmation = params[key][:password_confirmation]

      respond_to do |format|
        if @user.save
          format.html { respond_with resource, :location => after_sign_in_path_for(resource) }
          format.js { render 'successful_registration', :layout => false }
        else
          format.html { respond_with resource, :location => after_sign_in_path_for(resource) }
          format.js { render 'errors', :layout => false }
        end
      end

      @registration_resource = resource
    end

  end
end
