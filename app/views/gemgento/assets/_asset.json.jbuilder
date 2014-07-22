json.(asset, :id, :product_id, :url, :position, :file, :label, :sync_needed, :store_id, :asset_file_id, :created_at, :updated_at)

json.styles do |json|
  json.original asset.image.url(:original)

  asset.image.styles.keys.to_a.each do |style|
    json.set! style, asset.image.url(style.to_sym)
  end
end

json.types do |json|
  json.array! asset.asset_types.pluck(:code).uniq
end
