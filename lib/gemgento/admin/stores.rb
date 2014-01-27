if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register Store do
      menu priority: 100, parent: 'Gemgento', label: 'Stores'

      actions :all, :except => [:new, :destroy]

      index do
        column :name
        column :currency_code
        default_actions
      end

      form multipart: true do |f|
        f.inputs do
          f.input :currency_code
        end

        f.actions
      end

      controller do
        def permitted_params
          params.permit(
              :gemgento_store => [
                  :currency_code
              ])
        end
      end

    end
  end
end