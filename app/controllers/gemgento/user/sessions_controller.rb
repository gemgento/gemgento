module Gemgento
  class User::SessionsController < Devise::SessionsController
    respond_to :html, :json
    prepend_before_filter :convert_magento_password, only: :create

    # POST /resource/sign_in
    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?

      respond_to do |format|
        format.html { respond_with resource, location: after_sign_in_path_for(resource) }
        format.json do
          render json: {
              result: true,
              user: resource,
              csrfParam: request_forgery_protection_token,
              csrfToken: form_authenticity_token
          }
        end
      end
    end

    # DELETE /resource/sign_out
    def destroy
      redirect_path = after_sign_out_path_for(resource_name)
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      set_flash_message :notice, :signed_out if signed_out && is_navigational_format?

      # destroy the cart cookie when a user logs out
      session.delete :cart

      # We actually need to hardcode this as Rails default responder doesn't
      # support returning empty response on GET request
      respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) { redirect_to redirect_path }
      end
    end

    private

    def convert_magento_password
      Gemgento::User.is_valid_login params[:user][:email], params[:user][:password]
    end

  end
end
