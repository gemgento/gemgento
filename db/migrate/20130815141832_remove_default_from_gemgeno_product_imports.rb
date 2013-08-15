class RemoveDefaultFromGemgenoProductImports < ActiveRecord::Migration
  def up
    change_column_default :gemgento_product_imports, :include_images, nil
    change_column :gemgento_product_imports, :import_errors, :longtext
  end
end
