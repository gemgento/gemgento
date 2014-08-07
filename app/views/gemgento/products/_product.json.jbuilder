json.cache! [product, product.cache_expires_at, current_store, json_options] do
  json.(product, :id, :magento_id, :magento_type, :sku, :product_attribute_set_id, :status, :visibility, :swatch_id, :created_at, :updated_at, :deleted_at)
  json.currency_code current_store.currency_code
  json.configurable_product_ids product.configurable_products.active.pluck(:id)
  json.is_in_stock product.in_stock?(1, current_store)
  json.inventory product.inventories.find_by(store: current_store)
  json.category_ids Gemgento::ProductCategory.where(product: product, store: current_store).pluck(:category_id).uniq

  product.product_attribute_values.where(store: current_store).includes(:product_attribute).each do |attribute_value|
    json.set! attribute_value.product_attribute.code, product.attribute_value(attribute_value.product_attribute.code, current_store)
  end

  json.assets do |json|
    json.array! product.assets.where(store: current_store), partial: 'gemgento/assets/asset', as: :asset
  end

  if json_options[:include_simple_products]
    json.simple_products do |json|
      if json_options[:active]
        json.array! product.simple_products.active.eager, partial: 'gemgento/products/product', as: :product
      else
        json.array! product.simple_products.eager, partial: 'gemgento/products/product', as: :product
      end
    end
  else
    if json_options[:active]
      json.simple_product_ids product.simple_products.active.pluck(:id)
    else
      json.simple_product_ids product.simple_products.pluck(:id)
    end
  end

  if product.magento_type == 'configurable'
    if json_options[:active]
      json.configurable_attribute_order product.configurable_attribute_order(current_store)
    else
      json.configurable_attribute_order product.configurable_attribute_order(current_store, false)
    end
  end
end