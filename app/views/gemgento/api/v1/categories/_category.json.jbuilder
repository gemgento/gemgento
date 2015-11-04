json.type 'categories'
json.id category.id

json.attributes do
  json.extract! category, :name, :created_at, :updated_at, :include_in_menu, :is_active, :magento_id, :position, :url_key
end

json.relationships do
  if category.parent
    json.parent do
      json.data do
        json.type 'categories'
        json.id category.parent.id
      end
    end
  end

  if category.children.any?
    json.children do
      json.data do
        json.array! category.children do |child|
          json.type 'categories'
          json.id child.id
        end
      end
    end
  end

  if category.products(current_store).any?
    json.products do
      json.data do
        json.array! category.products do |product|
          json.type 'products'
          json.id product.id
        end
      end
    end
  end

  if category.stores.any?
    json.stores do
      json.data do
        json.array! category.stores do |store|
          json.type 'stores'
          json.id store.id
        end
      end
    end
  end
end
