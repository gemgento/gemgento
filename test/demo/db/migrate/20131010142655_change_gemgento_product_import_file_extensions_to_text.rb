class ChangeGemgentoProductImportFileExtensionsToText < ActiveRecord::Migration
  def change
    change_column :gemgento_product_imports, :image_file_extensions, :text, default: nil
  end
end
