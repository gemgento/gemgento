# This migration comes from gemgento (originally 20140625141601)
class AddQuantityToGemegentoShipmentItems < ActiveRecord::Migration
  def change
    add_column :gemegento_shipment_items, :quantity, :decimal, default: 0, null: false
  end
end
