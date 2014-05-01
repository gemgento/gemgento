if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register Sync do
      menu priority: 100, parent: 'Gemgento', label: 'Sync'
      permit_params :subject

      actions :all, :except => [:edit, :destroy]

      form do |f|
        f.inputs do
          f.input :subject, as: :select, collection: %w[attributes categories customers everything  products  orders]
        end
        f.actions
      end

      controller do
        def create
          Gemgento::Sync.send(params[:gemgento_sync][:subject])

          redirect_to admin_gemgento_syncs_url
        end
      end

    end
  end
end