json.data do
  json.type 'assets'
  json.id asset.id

  json.styles do
    json.array! asset.asset_file.file.styles.keys do |style|
      json.set! style, asset.image.url(style)
    end
  end
end


