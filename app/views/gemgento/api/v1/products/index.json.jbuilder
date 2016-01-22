json.meta do
  json.store current_store.id
  json.total_pages @products.total_pages
end

json.data do
  json.array! @products, partial: 'product', as: :product
end
