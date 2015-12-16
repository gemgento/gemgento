json.meta do
  json.store current_store.id
  json.total_pages @products.total_pages
end

json.data do
  json.array! @products, partial: 'gemgento/api/v1/products/product', as: :product
end
