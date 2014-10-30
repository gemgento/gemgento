class RenameGemgentoOrdersIdToMagentoId < ActiveRecord::Migration
  def change
    rename_column :gemgento_orders, :order_id, :magento_id
  end
end
