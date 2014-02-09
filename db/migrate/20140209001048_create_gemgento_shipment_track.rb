class CreateGemgentoShipmentTrack < ActiveRecord::Migration
  def up
    create_table :gemgento_shipment_tracks do |t|
      t.integer :shipment_id
      t.string :carrier_code
      t.string :title
      t.string :number
      t.integer :order_id
      t.integer :magento_id
    end

    add_index :gemgento_shipment_tracks, :shipment_id
  end

  def down
    drop_table :gemgento_shipment_tracks
  end
end
