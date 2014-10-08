if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register Subscriber do
      menu label: 'Subscribers', parent: 'Gemgento'

      permit_params :first_name, :last_name, :email

      index do
        column :email
        column :first_name
        column :last_name
        column :country
        column :city
        actions
      end

      form multipart: true do |f|
        f.inputs do
          f.input :email
          f.input :first_name
          f.input :last_name
          f.input :country
          f.input :city
        end

        f.actions
      end

    end
  end
end