module Gemgento
  class RegistrationsController < Devise::RegistrationsController
    layout 'application'

    def create
      @user = User.new
      @user.fname = params[:users][:fname]
      @user.lname = params[:users][:lname]
      @user.email = params[:users][:email]
      @user.store = Gemgento::Store.first
      @user.user_group = Gemgento::UserGroup.find_by(code: 'General')
      @user.magento_password = params[:users][:password]
      @user.password = params[:users][:password]
      @user.password_confirmation = params[:users][:password_confirmation]

      respond_to do |format|
        if @user.save
          sign_in(:users, @user)
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
