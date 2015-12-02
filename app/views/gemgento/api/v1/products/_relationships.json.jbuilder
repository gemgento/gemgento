if product.categories.any?
  json.categories do
    json.data do
      json.array! product.categories do |category|
        json.type 'categories'
        json.id category.id
      end
    end
  end
end

if product.stores.any?
  json.stores do
    json.data do
      json.array! product.stores do |store|
        json.type 'stores'
        json.id store.id
      end
    end
  end
end

if product.assets.where(store: current_store).any?
  json.assets do
    json.array! product.assets.where(store: current_store) do |asset|
      json.type 'assets'
      json.id asset.id
    end
  end
end

if product.configurable_products.any?
  json.configurable_products do
    json.array! product.configurable_products do |configurable_product|
      json.type 'products'
      json.id configurable_product.id
    end
  end
end

if product.simple_products.any?
  json.simple_products do
    json.array! product.simple_products do |simple_product|
      json.type 'products'
      json.id simple_product.id
    end
  end
end