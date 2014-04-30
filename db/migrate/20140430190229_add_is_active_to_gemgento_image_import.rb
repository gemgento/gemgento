class AddIsActiveToGemgentoImageImport < ActiveRecord::Migration
  def change
    add_column :gemgento_image_imports, :is_active, :boolean, default: false
  end
end
