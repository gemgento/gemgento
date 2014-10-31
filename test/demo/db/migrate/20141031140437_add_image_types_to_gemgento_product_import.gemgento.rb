# This migration comes from gemgento (originally 20131223181709)
class AddImageTypesToGemgentoProductImport < ActiveRecord::Migration
  def change
    add_column :gemgento_product_imports, :image_types, :text
  end
end
