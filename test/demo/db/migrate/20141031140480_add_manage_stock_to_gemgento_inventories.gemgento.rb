# This migration comes from gemgento (originally 20140725141407)
class AddManageStockToGemgentoInventories < ActiveRecord::Migration
  def change
    add_column :gemgento_inventories, :manage_stock, :boolean, default: true
  end
end
