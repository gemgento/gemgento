# This migration comes from gemgento (originally 20140605141601)
class AddBackordersToGemgentoInventories < ActiveRecord::Migration
  def change
    add_column :gemgento_inventories, :backorders, :integer, default: 0, null: false
    add_column :gemgento_inventories, :use_config_backorders, :boolean, default: true, null: false
    add_column :gemgento_inventories, :min_qty, :integer, default: 0, null: false
    add_column :gemgento_inventories, :use_config_min_qty, :boolean, default: true, null: false
  end
end
