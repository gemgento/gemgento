class ChangeGemgentoOrderMagentoIdToOrderId < ActiveRecord::Migration
  def change
    rename_column :gemgento_orders, :magento_id, :order_id
    change_column :gemgento_orders, :order_id, :integer, null: true
  end
end
