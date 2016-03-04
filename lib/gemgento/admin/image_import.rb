if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register ImageImport do
      menu priority: 200, parent: 'Gemgento', label: 'Image Import'
      actions :all, except: [:destroy]

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

      form as: :gemgento_image_import, multipart: true do |f|
        f.inputs do
          f.input :file, as: :file, label: 'Spreadsheet'
          f.input :store_id,
                  as: :select,
                  include_blank: false,
                  collection: Store.where.not(code: 'admin').map { |s| [s.name, s.id] }
          f.input :image_path, as: :string
          f.input :image_file_extensions_raw, as: :string, label: 'Image File Extensions', hint: 'Enter expected image file extensions. Separate extensions with a comma.  E.g. .jpg, .png, .gif'
          f.input :image_labels_raw, as: :text, label: 'Image Labels', hint: 'Enter image labels in order of appearance.  Separate labels with line breaks (hit enter)'
          f.input :image_types_raw, as: :text, label: 'Image Types', hint: 'The default image types are: small_image, image, thumbnail.  Each line corresponds to labels above, multiple types can be separated by a comma'
        end

        f.actions
      end

      show do |import|
        attributes_table do
          row :created_at

          row :spreadsheet do
            link_to import.file.instance_read(:file_name), import.file.url
          end

          row :image_path
          row :image_file_extensions
          row :image_labels
          row :image_types
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
          params.permit(
              gemgento_image_import: [
                  :file, :destroy_existing, :image_path, :image_file_extensions_raw, :image_labels_raw,
                  :image_types_raw, :store_id
              ]
          )
        end
      end

    end
  end
end