if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register ProductImport do
      menu :priority => 1, :parent => 'Gemgento'

      index do
        column :created_at
        actions :defaults => false
      end

      form multipart: true do |f|
        f.inputs do
          f.input :errors
          f.input :spreadsheet, as: :file, label: 'Spreadsheet'
        end

        f.actions
      end

    end
  end
end