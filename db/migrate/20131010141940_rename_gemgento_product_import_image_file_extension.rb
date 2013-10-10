class RenameGemgentoProductImportImageFileExtension < ActiveRecord::Migration
  def change
    rename_column :gemgento_product_imports, :image_file_extension, :image_file_extensions
  end
end