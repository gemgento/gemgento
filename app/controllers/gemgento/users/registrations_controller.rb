module Gemgento
  class Users::RegistrationsController < Devise::RegistrationsController
    include SslRequirement

    ssl_required :new, :create, :edit, :update, :destroy, :cancel

    # POST /resource
    def create
      build_resource(sign_up_params)
      resource.stores << current_store unless resource.stores.include? current_store
      resource.user_group = Gemgento::UserGroup.find_by(code: 'General')

      if resource.save
        yield resource if block_given?
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          respond_with resource, :location => after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        respond_with resource
      end
    end
  end
end
