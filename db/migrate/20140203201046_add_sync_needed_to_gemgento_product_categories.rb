class AddSyncNeededToGemgentoProductCategories < ActiveRecord::Migration
  def change
    add_column :gemgento_product_categories, :sync_needed, :boolean, default: false
  end
end
