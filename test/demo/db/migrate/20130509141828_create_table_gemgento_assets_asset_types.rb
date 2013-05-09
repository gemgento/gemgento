class CreateTableGemgentoAssetsAssetTypes < ActiveRecord::Migration
  def change
    create_table :gemgento_assets_asset_types, id: false do |t|
      t.integer    :asset_id
      t.integer    :asset_type_id
    end

    execute 'ALTER TABLE  `gemgento_assets_asset_types` ADD PRIMARY KEY (  `asset_id` ,  `asset_type_id` )'
  end
end
