# This migration comes from gemgento (originally 20140203201046)
class AddSyncNeededToGemgentoProductCategories < ActiveRecord::Migration
  def change
    add_column :gemgento_product_categories, :sync_needed, :boolean, default: false
  end
end
