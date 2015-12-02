json.type 'products'
json.id product.id

json.attributes do
  json.partial! 'gemgento/api/v1/products/attributes', product: product
end

json.relationships do
  json.partial! 'gemgento/api/v1/products/relationships', product: product
end

if product.assets.where(store: current_store).any?
  json.included do
    json.array! product.assets.where(store: current_store), partial: 'gemgento/shared/asset', as: :asset
  end
end
