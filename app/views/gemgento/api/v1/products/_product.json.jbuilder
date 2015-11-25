json.type 'products'
json.id product.id

json.attributes do
  json.extract! product, :created_at, :updated_at, :deleted_at, :magento_id, :magento_type, :sku, :visibility

  product.product_attribute_set.product_attributes.pluck(:code).each do |code|
    %w[tier_price group_price].include? code
    json.set! code.to_sym, product.attribute_value(code)
  end

  json.configurable_attribute_order product.configurable_attribute_order(current_store)
end

json.relationships do
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
        json.url asset.image.url(:medium)
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
end

if product.assets.where(store: current_store).any?
  json.included do
    json.array! product.assets.where(store: current_store), partial: 'gemgento/shared/asset', as: :asset
  end
end
