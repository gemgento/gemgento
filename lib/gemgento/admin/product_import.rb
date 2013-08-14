if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register ProductImport do
      menu :priority => 1, :parent => 'Gemgento'

      index do
        column :created_at
        column :count_created, label: 'Products Created'
        column :count_updated, label: 'Products Updated'
        actions :defaults => false
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
          f.input :include_images, as: :radio
          f.input :image_prefix
          f.input :image_suffix
          f.input :image_labels_raw, as: :text, label: 'Image Labels', hint: 'Enter image labels in appearance order.  Separate labels with line breaks (hit enter)'
        end

        f.actions
      end

    end
  end
end