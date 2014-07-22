json.(shipment, :id, :magento_id, :order_id, :increment_id, :store_id, :shipping_address_id, :total_qty, :created_at, :updated_at)
json.shipment_items do |json|
  json.array! shipment.shipment_items
end

json.shipment_comments do |json|
  json.array! shipment.shipment_comments
end

json.tracks do |json|
  json.array! json.shipment_tracks
end