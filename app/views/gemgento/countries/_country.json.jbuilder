json.cache! country do
  json.(country, :id, :magento_id, :iso2_code, :iso3_code, :name, :created_at, :updated_at)
  json.regions do |json|
    json.array! country.regions
  end
end
