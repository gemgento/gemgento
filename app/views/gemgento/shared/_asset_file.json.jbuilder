json.type 'asset_files'
json.id asset_file.id

json.data do
  json.styles do
    json.array! asset_file.file.styles.keys do |style|
      json.set! style, asset_file.file.url(style)
    end
  end
end


