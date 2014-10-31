# This migration comes from gemgento (originally 20140625141630)
class RenameGemegentoShipmentItems < ActiveRecord::Migration
  def change
    rename_table :gemegento_shipment_items, :gemgento_shipment_items
  end
end
