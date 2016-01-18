class RemoveSyncNeededFromGemgentoProductCategory < ActiveRecord::Migration
  def change
    remove_column :gemgento_product_categories, :sync_needed, :boolean, default: false
  end
end
