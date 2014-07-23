json.cache! 'countries' do
  json.array! @countries, partial: 'country', as: :country
end
