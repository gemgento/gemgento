class AddTimestampsToGemgentoAssetFiles < ActiveRecord::Migration
  def change
    add_column :gemgento_asset_files, :created_at, :datetime
    add_column :gemgento_asset_files, :updated_at, :datetime
  end
end
