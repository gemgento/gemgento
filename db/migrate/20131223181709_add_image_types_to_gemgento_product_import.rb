class AddImageTypesToGemgentoProductImport < ActiveRecord::Migration
  def change
    add_column :gemgento_product_imports, :image_types, :text
  end
end
