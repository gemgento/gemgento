class Remove < ActiveRecord::Migration
  def change
    change_column :gemgento_order_items, :magento_id, :integer, :null => true
  end
end
