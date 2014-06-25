class AddQuantityToGemegentoShipmentItems < ActiveRecord::Migration
  def change
    add_column :gemegento_shipment_items, :quantity, :decimal, default: 0, null: false
  end
end
