# This migration comes from gemgento (originally 20140209001048)
class CreateGemgentoShipmentTrack < ActiveRecord::Migration
  def up
    create_table :gemgento_shipment_tracks, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :shipment_id
      t.string :carrier_code
      t.string :title
      t.string :number
      t.integer :order_id
      t.integer :magento_id
    end

    add_index :gemgento_shipment_tracks, :shipment_id, name: 'shipment_tracks_shipment_index'
  end

  def down
    drop_table :gemgento_shipment_tracks
  end
end
