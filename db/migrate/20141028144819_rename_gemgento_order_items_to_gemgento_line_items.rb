class RenameGemgentoOrderItemsToGemgentoLineItems < ActiveRecord::Migration
  def change
    rename_table :gemgento_order_items, :gemgento_line_items
  end
end
