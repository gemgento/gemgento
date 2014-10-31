# This migration comes from gemgento (originally 20140910121424)
class AddCartItemErrorsToGemgentoOrders < ActiveRecord::Migration
  def change
    add_column :gemgento_orders, :cart_item_errors, :text
  end
end
