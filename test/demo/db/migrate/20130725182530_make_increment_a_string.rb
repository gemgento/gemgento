class MakeIncrementAString < ActiveRecord::Migration
  def change
    change_column :gemgento_orders, :order_id, :integer
    change_column :gemgento_orders, :increment_id, :string
  end
end
