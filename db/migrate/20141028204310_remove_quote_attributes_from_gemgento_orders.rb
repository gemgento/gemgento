class RemoveQuoteAttributesFromGemgentoOrders < ActiveRecord::Migration
  def change
    remove_column :gemgento_orders, :magento_quote_id, :integer
    remove_column :gemgento_orders, :is_active, :boolean, default: true
    remove_column :gemgento_orders, :cart_item_errors, :text
  end
end
