json.cache! 'countries', expires_in: 7.days do
  json.partial! partial: 'country', collection: @countries, as: :country
end
