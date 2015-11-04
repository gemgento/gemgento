json.type 'assets'
json.id asset.id

json.data do
  json.extract! asset, :position, :label, :file, :created_at, :updated_at, :url
end

json.relationships do
  if asset.asset_types.any?
    json.asset_types do
      json.array! asset.asset_types do |asset_type|
        json.type 'asset_types'
        json.id asset_type.id
      end
    end
  end

  json.store do
    json.type 'stores'
    json.id asset.store_id
  end

  json.asset_file do
    json.type 'asset_files'
    json.id asset.asset_file_id
  end
end

json.included do
  included_asset_types = json.array! asset.asset_types, partial: 'gemgento/shared/asset_type', as: :asset_type
  included_asset_file = json.array! [asset.asset_file], partial: 'gemgento/shared/asset_file', as: :asset_file
  included_asset_types + included_asset_file
end


