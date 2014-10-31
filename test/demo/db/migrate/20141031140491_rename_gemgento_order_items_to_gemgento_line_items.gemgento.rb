# This migration comes from gemgento (originally 20141028144819)
class RenameGemgentoOrderItemsToGemgentoLineItems < ActiveRecord::Migration
  def change
    rename_table :gemgento_order_items, :gemgento_line_items
  end
end
