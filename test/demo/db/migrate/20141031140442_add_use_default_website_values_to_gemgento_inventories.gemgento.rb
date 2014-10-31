# This migration comes from gemgento (originally 20140120124655)
class AddUseDefaultWebsiteValuesToGemgentoInventories < ActiveRecord::Migration
  def change
    add_column :gemgento_inventories, :use_default_website_stock, :boolean, default: true
  end
end
