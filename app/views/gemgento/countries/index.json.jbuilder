json.cache! ['countries', @countries.maximum(:updated_at)] do
  json.array! @countries, partial: 'country', as: :country
end
