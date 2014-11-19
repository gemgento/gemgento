class RenameGemgentoShipmentItemOrderItemToLineItem < ActiveRecord::Migration
  def change
    rename_column :gemgento_shipment_items, :order_item_id, :line_item_id
  end
end
