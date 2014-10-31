# This migration comes from gemgento (originally 20141028160826)
class CreateGemgentoQuote < ActiveRecord::Migration
  def change
    create_table :gemgento_quotes do |t|
      t.integer  :magento_id
      t.references :store
      t.references :user
      t.references :user_group
      t.references :order
      t.datetime :converted_at
      t.timestamps
      t.boolean :is_active, default: true
      t.boolean :is_virtual, default: false
      t.boolean :is_multi_shipping, default: false
      t.string :original_order_id
      t.decimal  :store_to_base_rate,          precision: 12, scale: 4, default: 1
      t.decimal  :store_to_quote_rate,         precision: 12, scale: 4, default: 1
      t.string   :base_currency_code
      t.string   :store_currency_code
      t.string   :quote_currency_code
      t.decimal  :grand_total,                 precision: 12, scale: 4
      t.decimal  :base_grand_total,            precision: 12, scale: 4
      t.string   :checkout_method
      t.string   :customer_email
      t.string   :customer_prefix
      t.string   :customer_first_name
      t.string   :customer_middle_name
      t.string   :customer_last_name
      t.string   :customer_suffix
      t.text     :customer_note
      t.boolean  :customer_note_notify, default: false
      t.boolean  :customer_is_guest, default: false
      t.string   :applied_rule_ids
      t.string   :reserved_order_id
      t.string   :password_hash
      t.string   :coupon_code
      t.string   :global_currency_code
      t.decimal  :base_to_global_rate,         precision: 12, scale: 4, default: 1
      t.decimal  :base_to_order_rate,          precision: 12, scale: 4, default: 1
      t.string   :customer_taxvat
      t.string   :customer_gender
      t.decimal  :subtotal,                    precision: 12, scale: 4
      t.decimal  :base_subtotal,               precision: 12, scale: 4
      t.decimal  :base_subtotal_with_discount, precision: 12, scale: 4
      t.string   :shipping_method
      t.text     :ext_shipping_info
      t.decimal  :shipping_amount,              precision: 12, scale: 4
      t.references :gift_message
      t.decimal  :customer_balance_amount_used, precision: 12, scale: 4
      t.decimal  :base_customer_balance_amount_used, precision: 12, scale: 4
      t.boolean :use_customer_balance, default: false
      t.decimal :gift_cards_amount,             precision: 12, scale: 4
      t.decimal :base_gift_cards_amount,        precision: 12, scale: 4
      t.boolean :use_reward_points, default: false
      t.decimal :reward_points_balance,         precision: 12, scale: 4
      t.decimal :reward_currency_amount,        precision: 12, scale: 4
      t.decimal :base_reward_currency_amount,   precision: 12, scale: 4
    end
  end
end
