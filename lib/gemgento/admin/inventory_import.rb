if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register InventoryImport do
      menu priority: 200, parent: 'Gemgento', label: 'Inventory Import'
      actions :all, except: [:destroy]
      permit_params :id, :spreadsheet

      form multipart: true do |f|
        f.inputs do
          f.input :spreadsheet, as: :file, label: 'Spreadsheet'
        end

        f.actions
      end

    end
  end
end