module Gemgento
  class RegistrationsController < Devise::RegistrationsController
    layout 'application'

    def create
      @user = User.new
      @user.fname = params[:user][:fname]
      @user.lname = params[:user][:lname]
      @user.email = params[:user][:email]
      @user.store = Gemgento::Store.first
      @user.user_group = Gemgento::UserGroup.where(code: 'General').first
      @user.magento_password = params[:user][:password]
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]

      respond_to do |format|
        if @user.save
          sign_in(:user, @user)
          format.html { render 'gemgento/users/info' }
          format.js { render 'gemgento/users/registrations/successful_registration', :layout => false }
        else
          format.html { 'gemgento/users/registrations/new' }
          format.js { render 'gemgento/users/registrations/errors', :layout => false }
        end
      end
    end

  end
end
