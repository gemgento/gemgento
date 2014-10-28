class RenameGemgentoOrderPaymentToGemgentoPayment < ActiveRecord::Migration
  def change
    rename_table :gemgento_order_payments, :gemgento_payments
  end
end
