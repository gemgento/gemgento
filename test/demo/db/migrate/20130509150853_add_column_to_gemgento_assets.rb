class AddColumnToGemgentoAssets < ActiveRecord::Migration
  def change
    add_column :gemgento_assets, :sync_needed, :boolean, null: false, default: true
  end
end
