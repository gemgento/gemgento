class RemoveDefaultValueFromGemgentoProductImportIncludeImages < ActiveRecord::Migration
  def change
    change_column :gemgento_product_imports, :include_images, :boolean
  end
end
