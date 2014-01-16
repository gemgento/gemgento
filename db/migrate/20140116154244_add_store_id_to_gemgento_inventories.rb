class AddStoreIdToGemgentoInventories < ActiveRecord::Migration
  def change
    add_column :gemgento_inventories, :store_id, :integer
  end
end
