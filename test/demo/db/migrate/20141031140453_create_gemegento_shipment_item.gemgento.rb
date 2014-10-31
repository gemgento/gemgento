# This migration comes from gemgento (originally 20140209000330)
class CreateGemegentoShipmentItem < ActiveRecord::Migration
  def change
    create_table :gemegento_shipment_items, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :shipment_id
      t.string  :sku
      t.string  :name
      t.integer :order_item_id
      t.integer :product_id
      t.float   :weight
      t.float   :price
      t.float   :qty
      t.integer :magento_id
    end

    add_index :gemegento_shipment_items, :shipment_id, name: 'shipment_items_shipment_id'
  end

  def down
    drop_table :gemegento_shipment_items
  end
end
