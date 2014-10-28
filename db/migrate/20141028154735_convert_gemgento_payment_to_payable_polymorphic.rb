class ConvertGemgentoPaymentToPayablePolymorphic < ActiveRecord::Migration
  def change
    remove_index :gemgento_payments, column: :order_id
    rename_column :gemgento_payments, :order_id, :payable_id
    add_column :gemgento_payments, :payable_type, :string, default: 'Gemgento::Order', after: :magento_id
    add_index :gemgento_payments, [:payable_type, :payable_id]
  end

  def up
    super
    change_column_default :gemgento_payments, :payable_type, :null
  end
end
