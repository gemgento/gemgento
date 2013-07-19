module Gemgento
  class SessionsController < Devise::SessionsController
    layout 'application'

    # GET /resource/sign_in
    def new
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)

      respond_to do |format|
        if user_signed_in?
          format.html { render 'gemgento/users/info' }
          format.js { render 'gemgento/users/sessions/successful_session', :layout => false }
        else
          format.html { render 'gemgento/users/sessions/new' }
          format.js { render 'gemgento/users/sessions/errors', :layout => false }
        end
      end
    end

    # POST /resource/sign_in
    def create
      user = User::is_valid_login(params[:users][:email], params[:users][:password])

      respond_to do |format|
        unless user.nil?
          sign_in(:users, user)
          format.html { render 'gemgento/users/info' }
          format.js { render '/gemgento/users/sessions/successful_session', :layout => false }
        else
          format.html { render 'gemgento/users/sessions/new' }
          format.js { render 'gemgento/users/sessions/errors', :layout => false }
        end
      end
    end
  end
end
