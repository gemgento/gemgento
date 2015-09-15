if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register ProductImport do
      menu priority: 100, parent: 'Gemgento', label: 'Product Import'
      actions :all, except: [:destroy]

      index do
        column :created_at

        column "Products Created" do |import|
          import.count_created
        end

        column "Products Updated" do |import|
          import.count_updated
        end

        column "Errors" do |import|
          import.import_errors.size
        end

        actions
      end

      form as: :gemgento_product_import, multipart: true do |f|
        f.inputs do
          f.input :spreadsheet, as: :file, label: 'Spreadsheet'
          f.input :product_attribute_set, as: :select, :include_blank => false, collection: ProductAttributeSet.all.map { |as| [as.name, as.id] }
          f.input :root_category, as: :select, :include_blank => false, collection: Category.all.map { |c| [c.name, c.id] }
          f.input :store, as: :select, :include_blank => false, collection: Store.where.not(code: 'admin').map { |s| [s.name, s.id] }
          f.input :configurable_attributes,
                  as: :check_boxes,
                  multiple: true,
                  collection: ProductAttribute.where(is_configurable: true, scope: 'global', frontend_input: 'select').map { |pa| [pa.code, pa.id] }
          f.input :simple_product_visibility,
                  as: :select,
                  include_blank: false,
                  collection: { 'Not Visible' => 1, 'Catalog' => 2, 'Search' => 3, 'Catalog, Search' => 4 }
          f.input :configurable_product_visibility,
                  as: :select,
                  include_blank: false,
                  collection:  { 'Not Visible' => 1, 'Catalog' => 2, 'Search' => 3, 'Catalog, Search' => 4 }
          f.input :set_default_inventory_values
          f.input :include_images
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
            link_to import.spreadsheet.instance_read(:file_name), import.spreadsheet.url
          end

          row :root_category
          row :store
          row :configurable_attributes
          row :import_errors
        end
      end

      controller do
        def permitted_params
          params.permit(
              gemgento_product_import: [
                  :configurable_attribute_ids,
                  :utf8,
                  :authenticity_token,
                  :commit,
                  :spreadsheet,
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