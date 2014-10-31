# This migration comes from gemgento (originally 20140429191504)
class CreateGemgentoImageImports < ActiveRecord::Migration
  def change
    create_table :gemgento_image_imports, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.text :import_errors
      t.attachment :spreadsheet
      t.boolean :destroy_existing, default: false
      t.integer :store_id
      t.integer :count_created
      t.integer :count_updated
      t.string :image_path
      t.text :image_labels
      t.text :image_file_extensions
      t.text :image_types
      t.timestamps
    end
  end
end
