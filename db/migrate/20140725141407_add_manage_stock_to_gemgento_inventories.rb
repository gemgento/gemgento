class AddManageStockToGemgentoInventories < ActiveRecord::Migration
  def change
    add_column :gemgento_inventories, :manage_stock, :boolean, default: true
  end
end
