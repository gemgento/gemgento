json.extract! product, :created_at, :updated_at, :deleted_at, :magento_id, :magento_type, :sku, :visibility, :status

product.product_attribute_set.product_attributes.pluck(:code).each do |code|
  # skip attribute codes that are already on the model
  next if (product.attributes.keys.map(&:to_s) + %w[tier_price group_price]).include? code
  json.set! code.to_sym, product.attribute_value(code)
end

json.configurable_attribute_order product.configurable_attribute_order(current_store)