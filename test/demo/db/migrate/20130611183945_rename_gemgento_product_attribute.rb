class RenameGemgentoProductAttribute < ActiveRecord::Migration
  def up
    rename_column :gemgento_products, :store_view, :store_id
  end

  def down
    rename_column :gemgento_products, :store_id, :store_view
  end
end
