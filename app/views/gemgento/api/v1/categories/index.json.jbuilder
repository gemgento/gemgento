json.meta do
  json.store current_store.id
  json.total_pages @categories.total_pages
end

json.data do
  json.array! @categories, partial: 'category', as: :category
end
