class ChangeMagentoIdColumnNames < ActiveRecord::Migration
  def change
    rename_column :gemgento_orders, :order_id, :magento_order_id
    rename_column :gemgento_orders, :quote_id, :magento_quote_id
  end
end
