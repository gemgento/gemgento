json.type 'asset_files'
json.id asset_file.id

json.data do
  json.extract! asset_file, :file_meta

  json.styles do
    json.array! asset_file.file.styles.keys do |style|
      json.set! style do
        json.url asset_file.file.url(style)
        json.path asset_file.file.path(style)
        json.width asset_file.file.width(style)
        json.height asset_file.file.height(style)
      end
    end
  end
end


