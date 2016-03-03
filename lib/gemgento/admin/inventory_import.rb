if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register InventoryImport do
      menu priority: 200, parent: 'Gemgento', label: 'Inventory Import'
      actions :all, except: [:destroy, :edit]

      index do
        column :created_at

        column :state do |import|
          import.state.humanize
        end

        column :progress do |import|
          number_to_percentage import.percentage_complete, precision: 0
        end

        column :errors do |import|
          import.process_errors.any? ? status_tag('yes', :ok) : status_tag('no')
        end

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
          f.input :file, as: :file, label: 'Spreadsheet'
        end

        f.actions
      end

      show do |import|
        attributes_table do
          row :created_at

          row :spreadsheet do
            link_to import.file.instance_read(:file_name), import.file.url
          end
        end

        panel 'Process Details' do
          attributes_table_for import do
            row :state
            row :progress do

              "#{number_to_percentage(import.percentage_complete, precision: 0)} (#{import.current_row} /#{import.total_rows})"
            end
          end
        end

        if import.process_errors.any?
          panel 'Process Errors' do
            table_for import.process_errors.map { |e| { error: e } } do |error|
              column :error
            end
          end
        end
      end

      controller do
        def permitted_params
          params.permit(gemgento_inventory_import: [:file])
        end
      end

    end
  end
end