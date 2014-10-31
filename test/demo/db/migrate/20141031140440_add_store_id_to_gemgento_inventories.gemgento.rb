# This migration comes from gemgento (originally 20140116154244)
class AddStoreIdToGemgentoInventories < ActiveRecord::Migration
  def change
    add_column :gemgento_inventories, :store_id, :integer
  end
end
