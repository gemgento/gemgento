json.(order_item, :id, :magento_id, :order_id, :quote_item_id, :product_id, :product_type, :product_options, :weight, :is_virtual, :sku, :name, :applied_rule_ids, :free_shipping, :is_qty_decimal, :no_discount, :qty_canceled, :qty_invoiced, :qty_ordered, :qty_refunded, :qty_shipped, :cost, :price, :base_price, :original_price, :base_original_price, :tax_percent, :tax_amount, :base_tax_amount, :tax_invoiced, :base_tax_invoiced, :discount_percent, :discount_amount, :base_discount_amount, :discount_invoiced, :base_discount_invoiced, :amount_refunded, :base_amount_refunded, :row_total, :base_row_total, :row_invoiced, :base_row_invoiced, :row_weight, :gift_message_id, :gift_message, :gift_message_available, :base_tax_before_discount, :tax_before_discount, :weee_tax_applied, :weee_tax_applied_amount, :weee_tax_applied_row_amount, :base_weee_tax_applied_amount, :base_weee_tax_applied_row_amount, :weee_tax_disposition, :weee_tax_row_disposition, :base_weee_tax_disposition, :base_weee_tax_row_disposition, :created_at, :updated_at)

if params[:include_products]
  json.product do |json|
    json.partial! 'gemgento/products/product', product: order_item.product
  end
end