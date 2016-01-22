json.meta do
  json.store current_store.id
end

json.data do
  json.partial! 'category', category: @category
end