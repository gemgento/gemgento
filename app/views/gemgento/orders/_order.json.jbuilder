json.(order, :id, :order_id, :store_id, :is_active, :user_id, :tax_amount, :shipping_amount, :discount_amount, :subtotal, :grand_total, :total_paid, :total_refunded, :total_qty_ordered, :total_canceled, :total_invoiced, :total_online_refunded, :total_offline_refunded, :base_tax_amount, :base_shipping_amount, :base_discount_amount, :base_subtotal, :base_grand_total, :base_total_paid, :base_total_refunded, :base_total_qty_ordered, :base_total_canceled, :base_total_invoiced, :base_total_online_refunded, :base_total_offline_refunded, :billing_address_id, :billing_first_name, :billing_last_name, :shipping_address_id, :shipping_first_name, :shipping_last_name, :billing_name, :shipping_name, :store_to_base_rate, :store_to_order_rate, :base_to_global_rate, :base_to_order_rate, :weight, :store_name, :remote_ip, :status, :state, :applied_rule_ids, :global_currency_code, :base_currency_code, :store_currency_code, :order_currency_code, :shipping_method, :shipping_description, :customer_email, :customer_firstname, :customer_lastname, :magento_quote_id, :is_virtual, :user_group_id, :customer_note_notify, :customer_is_guest, :email_sent, :increment_id, :gift_message_id, :gift_message, :created_at, :updated_at, :placed_at)

json.user do |json|
  json.partial! 'gemgento/users/user', user: order.user
end

json.line_items do |json|
  json.array! order.line_items, partial: 'gemgento/line_items/line_item', as: :line_item
end

json.shipping_address do |json|
  json.partial! 'gemgento/addresses/address', address: order.shipping_address
end

json.billing_address do |json|
  json.partial! 'gemgento/addresses/address', address: order.billing_address
end

json.payment do |json|
  json.partial! 'gemgento/order_statuses/order_status', payment: order.payment
end

json.order_statuses do |json|
  json.array! order.order_statuses
end

json.shipments do |json|
  json.array! order.shipments, partial: 'gemgento/shipments/shipment', as: :shipment
end
