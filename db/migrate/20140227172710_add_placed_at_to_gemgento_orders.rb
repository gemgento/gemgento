class AddPlacedAtToGemgentoOrders < ActiveRecord::Migration
  def change
    add_column :gemgento_orders, :placed_at, :datetime
  end
end
