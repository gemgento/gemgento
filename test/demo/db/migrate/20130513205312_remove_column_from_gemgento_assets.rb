class RemoveColumnFromGemgentoAssets < ActiveRecord::Migration
  def up
    remove_column :gemgento_assets, :type
  end

  def down
    add_column :gemgento_assets, :type, :string
  end
end
