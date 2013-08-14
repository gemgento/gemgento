if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register ProductImport do
      menu :priority => 1, :parent => 'Gemgento'

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
          f.input :product_attribute_set_id, as: :select, :include_blank => false, collection: ProductAttributeSet.all.map { |as| [as.name, as.id] }
          f.input :root_category_id, as: :select, :include_blank => false, collection: Category.all.map { |c| [c.name, c.id] }
          f.input :store_id, as: :select, :include_blank => false, collection: Store.all.map { |s| [s.name, s.id] }
          f.input :configurable_attributes,
                  as: :check_boxes,
                  multiple: true,
                  collection: ProductAttribute.where(is_configurable: true, scope: 'global', frontend_input: 'select').map { |pa| [pa.code, pa.id] }
          f.input :include_images, as: :radio
          f.input :image_path
          f.input :image_file_extension
          f.input :image_labels_raw, as: :text, label: 'Image Labels', hint: 'Enter image labels in appearance order.  Separate labels with line breaks (hit enter)'
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

    end
  end
end