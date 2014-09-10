class AddCartItemErrorsToGemgentoOrders < ActiveRecord::Migration
  def change
    add_column :gemgento_orders, :cart_item_errors, :text
  end
end
