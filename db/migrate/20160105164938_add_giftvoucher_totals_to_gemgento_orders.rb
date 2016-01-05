class AddGiftvoucherTotalsToGemgentoOrders < ActiveRecord::Migration
  def change
    add_column :gemgento_orders, :base_giftvoucher_discount_for_shipping, :decimal
    add_column :gemgento_orders, :giftvoucher_discount_for_shipping, :decimal
    add_column :gemgento_orders, :base_giftcredit_discount_for_shipping, :decimal
    add_column :gemgento_orders, :giftcredit_discount_for_shipping, :decimal
    add_column :gemgento_orders, :base_gift_voucher_discount, :decimal
    add_column :gemgento_orders, :gift_voucher_discount, :decimal
    add_column :gemgento_orders, :base_use_gift_credit_amount, :decimal
    add_column :gemgento_orders, :use_gift_credit_amount, :decimal
    add_column :gemgento_orders, :giftvoucher_base_hidden_tax_amount, :decimal
    add_column :gemgento_orders, :giftvoucher_hidden_tax_amount, :decimal
    add_column :gemgento_orders, :giftcredit_base_hidden_tax_amount, :decimal
    add_column :gemgento_orders, :giftcredit_hidden_tax_amount, :decimal
    add_column :gemgento_orders, :giftcredit_base_shipping_hidden_tax_amount, :decimal
    add_column :gemgento_orders, :giftcredit_shipping_hidden_tax_amount, :decimal
  end
end