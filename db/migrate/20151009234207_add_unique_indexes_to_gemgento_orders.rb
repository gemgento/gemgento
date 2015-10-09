class AddUniqueIndexesToGemgentoOrders < ActiveRecord::Migration
  def change
    add_index :gemgento_orders, :increment_id, unique: true
    add_index :gemgento_orders, :magento_id, unique: true
  end
end
