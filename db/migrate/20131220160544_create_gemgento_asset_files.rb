class CreateGemgentoAssetFiles < ActiveRecord::Migration
  def up
    add_column :gemgento_assets, :store_id, :integer
    add_column :gemgento_assets, :asset_file_id, :integer

    create_table :gemgento_asset_files do |t|
      t.attachment :file
    end

    remove_attachment :gemgento_assets, :attachment
  end

  def down
    add_attachment :gemgento_assets, :attachment
    drop_table :gemgento_asset_files
    remove_column :gemgento_assets, :store_id
    remove_column :gemgento_assets, :asset_file_id
  end
end
