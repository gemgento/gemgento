json.meta do
  json.store current_store.id
end

json.data do
  json.partial! 'product', product: @product
end