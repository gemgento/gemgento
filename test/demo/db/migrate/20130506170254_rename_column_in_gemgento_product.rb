class RenameColumnInGemgentoProduct < ActiveRecord::Migration
  def up
    rename_column :gemgento_products, :set, :product_attribute_set_id
  end

  def down
    rename_column :gemgento_products, :product_attribute_set_id, :set
  end
end
