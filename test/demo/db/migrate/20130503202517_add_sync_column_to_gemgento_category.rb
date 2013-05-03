class AddSyncColumnToGemgentoCategory < ActiveRecord::Migration
  def change
    add_column :gemgento_categories, :sync_needed, :boolean
    add_index :gemgento_categories, :magento_id, unique: true
  end
end
