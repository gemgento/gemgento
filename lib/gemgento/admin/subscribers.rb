if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register Subscriber do
      menu label: 'Subscribers'

      index do
        column :email
        column :name
        default_actions
      end

      form multipart: true do |f|
        f.inputs do
          f.input :email
          f.input :name
        end

        f.actions
      end

      controller do
        def permitted_params
          params.permit(
              :gemgento_subscriber => [
                  :name,
                  :email
              ])
        end
      end

    end
  end
end