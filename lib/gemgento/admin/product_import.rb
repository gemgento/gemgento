if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register ProductImport do
      menu priority: 100, parent: 'Gemgento', label: 'Product Import'
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

      form as: :gemgento_product_import, multipart: true do |f|
        f.inputs do
          f.input :file, as: :file, label: 'Spreadsheet'
          f.input :product_attribute_set_id,
                  as: :select,
                  include_blank: false,
                  collection: ProductAttributeSet.all.map { |as| [as.name, as.id] }
          f.input :root_category_id,
                  as: :select,
                  include_blank:
                      false, collection: Category.all.map { |c| [c.name, c.id] }
          f.input :store_id,
                  as: :select,
                  include_blank: false,
                  collection: Store.where.not(code: 'admin').map { |s| [s.name, s.id] }
          f.input :configurable_attribute_ids,
                  as: :check_boxes,
                  multiple: true,
                  collection: ProductAttribute
                                  .where(is_configurable: true, scope: 'global', frontend_input: 'select')
                                  .map { |pa| [pa.code, pa.id] }
          f.input :simple_product_visibility,
                  as: :select,
                  include_blank: false,
                  collection: { 'Not Visible' => 1, 'Catalog' => 2, 'Search' => 3, 'Catalog, Search' => 4 }
          f.input :configurable_product_visibility,
                  as: :select,
                  include_blank: false,
                  collection:  { 'Not Visible' => 1, 'Catalog' => 2, 'Search' => 3, 'Catalog, Search' => 4 }
          f.input :set_default_inventory_values, as: :boolean
          f.input :include_images, as: :boolean
          f.input :image_path
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

          row :root_category
          row :store
          row :configurable_attributes
          row :simple_product_visibility
          row :configurable_product_visibility
          row :set_default_inventory_values
        end

        panel 'Image Details' do
          attributes_table_for import do
            row :include_images
            row :image_path
            row :image_file_extensions
            row :image_labels
            row :image_types
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
          params.permit(
              gemgento_product_import: [
                  :utf8,
                  :authenticity_token,
                  :commit,
                  :file,
                  :product_attribute_set_id,
                  :root_category_id,
                  :store_id,
                  :configurable_attribute_ids,
                  :simple_product_visibility,
                  :configurable_product_visibility,
                  :include_images,
                  :image_path,
                  :image_file_extensions,
                  :image_file_extensions_raw,
                  :image_labels,
                  :image_labels_raw,
                  :image_types_raw,
                  :set_default_inventory_values
              ])
        end
      end

    end
  end
end