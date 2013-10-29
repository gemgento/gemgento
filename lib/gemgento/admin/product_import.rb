if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register ProductImport do
      menu priority: 1, parent: 'Gemgento', label: 'Product Import'

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
        actions :defaults => false do |pi|
          link_to 'Show', admin_gemgento_product_import_path(pi)
        end
      end

      form multipart: true do |f|
        f.inputs do
          f.input :spreadsheet, as: :file, label: 'Spreadsheet'
          f.input :product_attribute_set, as: :select, :include_blank => false, collection: ProductAttributeSet.all.map { |as| [as.name, as.id] }
          f.input :root_category, as: :select, :include_blank => false, collection: Category.all.map { |c| [c.name, c.id] }
          f.input :store, as: :select, :include_blank => false, collection: Store.all.map { |s| [s.name, s.id] }
          f.input :configurable_attributes,
                  as: :check_boxes,
                  multiple: true,
                  collection: ProductAttribute.where(is_configurable: true, scope: 'global', frontend_input: 'select').map { |pa| [pa.code, pa.id] }
          f.input :simple_product_visibility,
                  as: :select,
                  include_blank: false,
                  collection: {'Not Visible' => 1, 'Catalog' => 2, 'Search' => 3, 'Catalog, Search' => 4}
          f.input :configurable_product_visibility,
                  as: :select,
                  include_blank: false,
                  collection: {'Not Visible' => 1, 'Catalog' => 2, 'Search' => 3, 'Catalog, Search' => 4}
          f.input :include_images
          f.input :image_path
          f.input :image_file_extensions_raw, as: :string, label: 'Image File Extensions', hint: 'Enter expected image file extensions. Separate extensions with a comma.  E.g. .jpg, .png, .gif'
          f.input :image_labels_raw, as: :text, label: 'Image Labels', hint: 'Enter image labels in order of appearance.  Separate labels with line breaks (hit enter)'
        end

        f.actions
      end

      show do |import|
        attributes_table do
          row :created_at

          row :spreadsheet do
            link_to import.spreadsheet.instance_read(:file_name), import.spreadsheet.url
          end

          row :root_category do
            import.root_category.name unless import.store.nil?
          end

          row :store do
            import.store.name unless import.store.nil?
          end

          row :configurable_attributes
        end
      end

      controller do
        def permitted_params
          params.permit(
              :gemgento_product_import => [
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
                  :image_labels_raw
              ])
        end
      end

    end
  end
end