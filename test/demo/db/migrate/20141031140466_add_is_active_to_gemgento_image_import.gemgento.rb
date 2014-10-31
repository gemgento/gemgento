# This migration comes from gemgento (originally 20140430190229)
class AddIsActiveToGemgentoImageImport < ActiveRecord::Migration
  def change
    add_column :gemgento_image_imports, :is_active, :boolean, default: false
  end
end
