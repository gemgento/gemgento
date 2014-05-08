if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register Page do

      index do
        column :name
        column :description
        column :permalink
        column :show_in_main_nav
        column :is_shop_landing
        default_actions
      end

      form multipart: true do |f|
        f.inputs do
          f.input :name
          f.input :description
          f.input :permalink
          f.input :body
          f.input :show_in_main_nav
          f.input :is_shop_landing
          f.input :position
        end

        f.actions
      end

      controller do
        def permitted_params
          params.permit(
              :gemgento_page => [
                  :name,
                  :description,
                  :permalink, 
                  :body,
                  :show_in_main_nav,
                  :is_shop_landing,
                  :position
              ])
        end
      end
    end
  end
end