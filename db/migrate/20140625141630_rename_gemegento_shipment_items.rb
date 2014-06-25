class RenameGemegentoShipmentItems < ActiveRecord::Migration
  def change
    rename_table :gemegento_shipment_items, :gemgento_shipment_items
  end
end
