json.cache! [category, current_store, json_options] do
  json.(category, :id, :magento_id, :name, :url_key, :parent_id, :position, :is_active, :include_in_menu, :created_at, :updated_at)

  if json_options[:include_products]
    json.products do |json|
      if json_options[:active]
        json.array! category.products.catalog_visible.active, partial: 'gemgento/products/product', as: :product
      else
        json.array! category.products.catalog_visible, partial: 'gemgento/products/product', as: :product
      end
    end
  end
end
