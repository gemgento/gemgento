class AllowNullValuesOnOrderPayments < ActiveRecord::Migration
  def change
    change_column :gemgento_order_payments, :is_active, :boolean, null: true
  end
end
