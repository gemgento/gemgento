class RemoveSyncNeededFromGemgentoCategories < ActiveRecord::Migration
  def change
    remove_column :gemgento_categories, :sync_needed, :boolean, default: false
  end
end
