if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register InventoryImport do
      menu priority: 200, parent: 'Gemgento', label: 'Inventory Import'
      actions :all, except: [:destroy]

      form as: :gemgento_inventory_import, multipart: true do |f|
        f.inputs do
          f.input :spreadsheet, as: :file, label: 'Spreadsheet'
        end

        f.actions
      end

      controller do
        def permitted_params
          params.permit(gemgento_inventory_import: [:id, :spreadsheet])
        end
      end

    end
  end
end