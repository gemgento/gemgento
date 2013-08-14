class AddMissingAttributesToGemgentoProductImport < ActiveRecord::Migration
  def change
    add_column :gemgento_product_imports, :include_images, :boolean, default: true
    add_column :gemgento_product_imports, :image_prefix, :string
    add_column :gemgento_product_imports, :image_suffix, :string
    add_column :gemgento_product_imports, :image_labels, :text
    add_column :gemgento_product_imports, :store_id, :integer
    add_column :gemgento_product_imports, :root_category_id, :integer
    add_column :gemgento_product_imports, :product_attribute_set_id, :integer
    add_column :gemgento_product_imports, :count_created, :integer
    add_column :gemgento_product_imports, :count_updated, :integer

    create_table :gemgento_product_imports_configurable_attributes, id: false do |t|
      t.integer :product_import_id, default: 0, null: false
      t.integer :product_attribute_id, default: 0, null: false
    end

  end
end
