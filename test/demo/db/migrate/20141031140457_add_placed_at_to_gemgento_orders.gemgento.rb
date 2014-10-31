# This migration comes from gemgento (originally 20140227172710)
class AddPlacedAtToGemgentoOrders < ActiveRecord::Migration
  def change
    add_column :gemgento_orders, :placed_at, :datetime
  end
end
