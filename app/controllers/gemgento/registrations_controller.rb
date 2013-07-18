module Gemgento
  class RegistrationsController < Devise::RegistrationsController
    layout 'application'

    def create
      super
      @registration_resource = resource
    end
    #def create
    #  @user = User.new
    #  @user.fname = params[:user][:fname]
    #  @user.lname = params[:user][:lname]
    #  @user.email = params[:user][:email]
    #  @user.store = Gemgento::Store.first
    #  @user.user_group = Gemgento::UserGroup.find_by(code: 'General')
    #  @user.magento_password = params[:user][:password]
    #  @user.password = params[:user][:password]
    #  @user.password_confirmation = params[:user][:password_confirmation]
    #
    #  if @user.save
    #    unless params[:user][:redirect].nil?
    #      redirect_to params[:user][:redirect]
    #    else
    #      respond_with resource, :location => after_sign_in_path_for(resource)
    #    end
    #  else
    #    redirect_to request.referer
    #  end
    #end

  end
end
