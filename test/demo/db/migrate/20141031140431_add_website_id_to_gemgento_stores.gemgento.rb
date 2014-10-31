# This migration comes from gemgento (originally 20131122183022)
class AddWebsiteIdToGemgentoStores < ActiveRecord::Migration
  def change
    add_column :gemgento_stores, :website_id, :integer
  end
end
