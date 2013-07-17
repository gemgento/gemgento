module Gemgento
  class RegistrationsController < Devise::RegistrationsController
    layout 'application'

    def create
      @user = User.new
      @user.fname = params[:user][:fname]
      @user.lname = params[:user][:lname]
      @user.email = params[:user][:email]
      @user.store = Gemgento::Store.first
      @user.user_group = Gemgento::UserGroup.find_by(code: 'General')
      @user.magento_password = params[:user][:password]
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]

      logger.info 'user = '+@user.inspect
      respond_to do |format|
        if @user.save
          sign_in @user
          format.html
          format.js { render 'successful_registration', :layout => false }
        else
          format.html
          format.js { render 'errors', :layout => false }
        end
      end
    end

  end
end
