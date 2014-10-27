if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register ImageImport do
      menu priority: 200, parent: 'Gemgento', label: 'Image Import'
      actions :all, except: [:destroy]

      index do
        column :created_at
        column :spreadsheet_file_name
        column :destroy_existing
        column :store

        column "Errors" do |import|
          import.import_errors.size
        end

        actions
      end

      form as: :gemgento_image_import, multipart: true do |f|
        f.inputs do
          f.input :spreadsheet, as: :file, label: 'Spreadsheet'
          f.input :store, as: :select, :include_blank => false, collection: Store.all.map { |s| [s.name, s.id] }
          f.input :destroy_existing
          f.input :image_path
          f.input :image_file_extensions_raw, as: :string, label: 'Image File Extensions', hint: 'Enter expected image file extensions. Separate extensions with a comma.  E.g. .jpg, .png, .gif'
          f.input :image_labels_raw, as: :text, label: 'Image Labels', hint: 'Enter image labels in order of appearance.  Separate labels with line breaks (hit enter)'
          f.input :image_types_raw, as: :text, label: 'Image Types', hint: 'The default image types are: small_image, image, thumbnail.  Each line corresponds to labels above, multiple types can be separated by a comma'
        end

        f.actions
      end

      controller do
        def permitted_params
          params.permit(
              gemgento_image_import: [
                  :spreadsheet, :destroy_existing, :image_path, :image_file_extensions_raw, :image_labels_raw,
                  :image_types_raw, :store_id
              ]
          )
        end
      end

    end
  end
end