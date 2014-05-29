if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register FooterItem do
      menu priority: 100, parent: 'Gemgento', label: 'Footer Item'

      index do
        column :name
        column :position
        column :url
        default_actions
      end

      form multipart: true do |f|
        f.inputs do
          f.input :name
          f.input :position
          f.input :url
        end

        f.actions
      end

      controller do
        def permitted_params
          params.permit(
              :gemgento_footer_item => [
                  :name,
                  :position,
                  :url
              ])
        end
      end
    end
  end
end