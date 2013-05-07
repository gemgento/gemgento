class AddColumnsToGemgentoAssets < ActiveRecord::Migration
  def change
    add_column :gemgento_assets, :file, :string
    add_column :gemgento_assets, :label, :string
  end
end
