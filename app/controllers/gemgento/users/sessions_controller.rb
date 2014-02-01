module Gemgento
  class Users::SessionsController < Devise::SessionsController
    include SslRequirement
    ssl_required :new, :create, :destroy
    respond_to :html, :json

    # POST /resource/sign_in
    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?

      respond_to do |format|
        format.html { respond_with resource, :location => after_sign_in_path_for(resource) }
        format.json { render json: { result: true, user: resource } }
      end

    end

    # DELETE /resource/sign_out
    def destroy
      redirect_path = after_sign_out_path_for(resource_name)
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      set_flash_message :notice, :signed_out if signed_out && is_navigational_format?

      if !current_order.id.nil? && current_order.state == 'cart'
        current_order.user_id = nil
        current_order.magento_quote_id = nil
        current_order.save
      end

      # We actually need to hardcode this as Rails default responder doesn't
      # support returning empty response on GET request
      respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) { redirect_to redirect_path }
      end
    end

  end
end
