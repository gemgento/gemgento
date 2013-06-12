class CreateTableGemgentoOrders < ActiveRecord::Migration
  def change
    create_table :gemgento_orders do |t|
      t.integer   :magento_id, null: false
      t.integer   :store_id, null: false
      t.boolean   :is_active
      t.integer   :user_id
      t.decimal   :tax_amount, precision: 12, scale: 4
      t.decimal   :shipping_amount, precision: 12, scale: 4
      t.decimal   :discount_amount, precision: 12, scale: 4
      t.decimal   :subtotal, precision: 12, scale: 4
      t.decimal   :grand_total, precision: 12, scale: 4
      t.decimal   :total_paid, precision: 12, scale: 4
      t.decimal   :total_refunded, precision: 12, scale: 4
      t.decimal   :total_qty_ordered, precision: 12, scale: 4
      t.decimal   :total_canceled, precision: 12, scale: 4
      t.decimal   :total_invoiced, precision: 12, scale: 4
      t.decimal   :total_online_refunded, precision: 12, scale: 4
      t.decimal   :total_offline_refunded, precision: 12, scale: 4
      t.decimal   :base_tax_amount, precision: 12, scale: 4
      t.decimal   :base_shipping_amount, precision: 12, scale: 4
      t.decimal   :base_discount_amount, precision: 12, scale: 4
      t.decimal   :base_subtotal, precision: 12, scale: 4
      t.decimal   :base_grand_total, precision: 12, scale: 4
      t.decimal   :base_total_paid, precision: 12, scale: 4
      t.decimal   :base_total_refunded, precision: 12, scale: 4
      t.decimal   :base_total_qty_ordered, precision: 12, scale: 4
      t.decimal   :base_total_canceled, precision: 12, scale: 4
      t.decimal   :base_total_invoiced, precision: 12, scale: 4
      t.decimal   :base_total_online_refunded, precision: 12, scale: 4
      t.decimal   :base_total_offline_refunded, precision: 12, scale: 4
      t.integer   :billing_address_id
      t.string    :billing_fname
      t.string    :billing_lname
      t.integer   :shipping_address_id
      t.string    :shipping_fname
      t.string    :shipping_lname
      t.string    :billing_name
      t.string    :shipping_name
      t.string    :store_to_base_rate
      t.string    :store_to_order_rate
      t.string    :base_to_global_rate
      t.string    :base_to_order_rate
      t.decimal   :weight, precision: 12, scale: 4
      t.string    :store_name
      t.string    :remote_ip
      t.string    :status
      t.string    :state
      t.string    :applied_rule_ids
      t.string    :global_currency_code
      t.string    :base_currency_code
      t.string    :store_currency_code
      t.string    :order_currency_code
      t.string    :shipping_method
      t.string    :shipping_description
      t.string    :customer_email
      t.string    :customer_firstname
      t.string    :customer_lastname
      t.string    :quote_id
      t.boolean   :is_virtual
      t.integer   :user_group_id
      t.string    :customer_note_notify
      t.boolean   :customer_is_guest
      t.boolean   :email_sent
      t.integer   :increment_id
      t.string    :gift_message_id
      t.string    :gift_message
      t.timestamps
    end
  end
end
