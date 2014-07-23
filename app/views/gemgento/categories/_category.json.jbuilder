json.cache! [category, current_store, json_options, params[:page], params[:per]] do
  json.(category, :id, :magento_id, :name, :url_key, :parent_id, :position, :is_active, :include_in_menu, :created_at, :updated_at)

  if json_options[:include_products]
    json.products do |json|
      json.array! products, partial: 'gemgento/products/product', as: :product
    end
  end
end
