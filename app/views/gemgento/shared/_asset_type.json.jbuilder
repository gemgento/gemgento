json.type 'asset_types'
json.id asset_type.id

json.data do
  json.extract! asset_type, :code, :created_at, :updated_at, :scope, :code
end

json.relationships do
  json.product_attribute_set do
    json.type 'product_attribute_sets'
    json.id asset_type.product_attribute_set_id
  end
end