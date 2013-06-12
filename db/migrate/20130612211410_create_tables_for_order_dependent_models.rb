class CreateTablesForOrderDependentModels < ActiveRecord::Migration
  def change
    create_table :gemgento_order_addresses do |t|
      t.integer     :order_id, null: false
      t.integer     :increment_id
      t.boolean     :is_active, null: false, default: true
      t.string      :address_type
      t.string      :fname
      t.string      :lname
      t.string      :company_name
      t.string      :street
      t.string      :city
      t.string      :region_name
      t.integer     :region_id
      t.string      :postcode
      t.integer     :country_id
      t.string      :telephone
      t.string      :fax
      t.integer     :address_id
      t.timestamps
    end

    create_table :gemgento_order_items do |t|
      t.integer     :magento_id, null: false
      t.integer     :order_id
      t.integer     :quote_item_id
      t.integer     :product_id
      t.string      :product_type
      t.string      :product_options
      t.decimal     :weight, precision: 12, scale: 4
      t.boolean     :is_virtual
      t.string      :sku
      t.string      :name
      t.string      :applied_rule_ids
      t.boolean     :free_shipping
      t.boolean     :is_qty_decimal
      t.boolean     :no_discount
      t.decimal     :qty_canceled, precision: 12, scale: 4
      t.decimal     :qty_invoiced, precision: 12, scale: 4
      t.decimal     :qty_ordered, precision: 12, scale: 4
      t.decimal     :qty_refunded, precision: 12, scale: 4
      t.decimal     :qty_shipped, precision: 12, scale: 4
      t.decimal     :cost, precision: 12, scale: 4
      t.decimal     :price, precision: 12, scale: 4
      t.decimal     :base_price, precision: 12, scale: 4
      t.decimal     :original_price, precision: 12, scale: 4
      t.decimal     :base_original_price, precision: 12, scale: 4
      t.decimal     :tax_percent, precision: 12, scale: 4
      t.decimal     :tax_amount, precision: 12, scale: 4
      t.decimal     :base_tax_amount, precision: 12, scale: 4
      t.decimal     :tax_invoiced, precision: 12, scale: 4
      t.decimal     :base_tax_invoiced, precision: 12, scale: 4
      t.decimal     :discount_percent, precision: 12, scale: 4
      t.decimal     :discount_amount, precision: 12, scale: 4
      t.decimal     :base_discount_amount, precision: 12, scale: 4
      t.decimal     :discount_invoiced, precision: 12, scale: 4
      t.decimal     :base_discount_invoiced, precision: 12, scale: 4
      t.decimal     :amount_refunded, precision: 12, scale: 4
      t.decimal     :base_amount_refunded, precision: 12, scale: 4
      t.decimal     :row_total, precision: 12, scale: 4
      t.decimal     :base_row_total, precision: 12, scale: 4
      t.decimal     :row_invoiced, precision: 12, scale: 4
      t.decimal     :base_row_invoiced, precision: 12, scale: 4
      t.decimal     :row_weight, precision: 12, scale: 4
      t.string      :gift_message_id
      t.string      :gift_message
      t.string      :gift_message_available
      t.decimal     :base_tax_before_discount, precision: 12, scale: 4
      t.decimal     :tax_before_discount, precision: 12, scale: 4
      t.decimal     :weee_tax_applied, precision: 12, scale: 4
      t.decimal     :weee_tax_applied_amount, precision: 12, scale: 4
      t.decimal     :weee_tax_applied_row_amount, precision: 12, scale: 4
      t.decimal     :base_weee_tax_applied_amount, precision: 12, scale: 4
      t.decimal     :base_weee_tax_applied_row_amount, precision: 12, scale: 4
      t.decimal     :weee_tax_disposition, precision: 12, scale: 4
      t.decimal     :weee_tax_row_disposition, precision: 12, scale: 4
      t.decimal     :base_weee_tax_disposition, precision: 12, scale: 4
      t.decimal     :base_weee_tax_row_disposition, precision: 12, scale: 4
      t.timestamps
    end

    create_table :gemgento_order_payments do |t|
      t.integer     :payment_id
      t.integer     :order_id, null: false
      t.integer     :increment_id
      t.boolean     :is_active, null: false, default: true
      t.decimal     :amount_ordered, precision: 12, scale: 4
      t.decimal     :shipping_amount, precision: 12, scale: 4
      t.decimal     :base_amount_ordered, precision: 12, scale: 4
      t.decimal     :base_shipping_amount, precision: 12, scale: 4
      t.string      :method
      t.string      :po_number
      t.string      :cc_type
      t.string      :cc_number_enc
      t.string      :cc_last4
      t.string      :cc_owner
      t.integer     :cc_exp_month
      t.integer     :cc_exp_year
      t.integer     :cc_ss_start_month
      t.integer     :cc_ss_start_year
      t.timestamps
    end

    create_table :gemgento_order_status_histories do |t|
      t.integer     :order_id, null: false
      t.integer     :increment_id
      t.boolean     :is_active, null: false, default: true
      t.boolean     :is_customer_notified, null: false, default: true
      t.string      :status
      t.string      :comment
      t.timestamps
    end
  end
end
