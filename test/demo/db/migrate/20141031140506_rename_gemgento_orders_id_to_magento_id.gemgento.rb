# This migration comes from gemgento (originally 20141030150545)
class RenameGemgentoOrdersIdToMagentoId < ActiveRecord::Migration
  def change
    rename_column :gemgento_orders, :order_id, :magento_id
  end
end
