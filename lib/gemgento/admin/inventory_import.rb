if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register InventoryImport do
      menu priority: 200, parent: 'Gemgento', label: 'Inventory Import'
      actions :all, except: [:destroy, :edit]

      index do
        column :created_at do |import|
          import.spreadsheet_updated_at.strftime('%F')
        end
        column :spreadsheet do |import|
          link_to import.spreadsheet.instance_read(:file_name), import.spreadsheet.url
        end
        column :is_active

        actions
      end

      show do |import|
        attributes_table do
          row :created_at

          row :spreadsheet do
            link_to import.spreadsheet.instance_read(:file_name), import.spreadsheet.url
          end

          row :import_errors
        end
      end

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