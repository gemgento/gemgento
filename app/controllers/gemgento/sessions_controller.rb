module Gemgento
  class SessionsController < Devise::SessionsController
    layout 'application'

    # GET /resource/sign_in
    def new
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      logger.info

      respond_to do |format|
        if user_signed_in?
          format.html { respond_with(resource, serialize_options(resource)) }
          format.js { render 'successful_session', :layout => false }
        else
          format.html { respond_with(resource, serialize_options(resource)) }
          format.js { render 'errors', :layout => false }
        end
      end
    end

    # POST /resource/sign_in
    def create
      key = params[:user].nil? ? :checkout : :user
      user = User.find_by(email: params[key][:email])

      respond_to do |format|
        if !user.nil? && user.valid_password?(params[key][:password])
          sign_in(:user, user)
          format.html { respond_with resource, :location => after_sign_in_path_for(resource) }
          format.js { render 'successful_session', :layout => false }
        else
          format.html { respond_with resource, :location => after_sign_in_path_for(resource) }
          format.js { render 'errors', :layout => false }
        end
      end

      @login_resource = resource
    end
  end
end
