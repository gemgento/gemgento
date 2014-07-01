class CreateGemgentoShipmentComment < ActiveRecord::Migration
  def change
    create_table :gemgento_shipment_comments, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer   :shipment_id
      t.text      :comment
      t.boolean   :is_customer_notified
      t.integer   :magento_id
      t.timestamps
    end
  end
end
