class AddDefaultsToGemgentoOrders < ActiveRecord::Migration
  def change
    change_column :gemgento_order_items, :magento_id, :integer, null: true, default: nil
  end
end