class AddUseDefaultWebsiteValuesToGemgentoInventories < ActiveRecord::Migration
  def change
    add_column :gemgento_inventories, :use_default_website_stock, :boolean, default: true
  end
end
