class CreateProductImport < ActiveRecord::Migration
  def change
    create_table :gemgento_product_imports do |t|
      t.text :import_errors
      t.timestamps
    end

    add_attachment :gemgento_product_imports, :spreadsheet
  end
end
