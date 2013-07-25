class ChnageOrderIdToString < ActiveRecord::Migration
  def change
    change_column :gemgento_orders, :order_id, :string
  end
end
