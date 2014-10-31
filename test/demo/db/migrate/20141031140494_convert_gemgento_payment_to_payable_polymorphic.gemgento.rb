# This migration comes from gemgento (originally 20141028154735)
class ConvertGemgentoPaymentToPayablePolymorphic < ActiveRecord::Migration
  def change
    rename_column :gemgento_payments, :order_id, :payable_id
    add_column :gemgento_payments, :payable_type, :string, default: 'Gemgento::Order', after: :magento_id
    add_index :gemgento_payments, [:payable_type, :payable_id]
  end

  def up
    super
    change_column_default :gemgento_payments, :payable_type, :null
  end
end
