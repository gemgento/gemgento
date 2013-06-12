class CreateTableGemgentoInventories < ActiveRecord::Migration
  def change
    create_table :gemgento_inventories do |t|
      t.integer     :product_id, null: false
      t.integer     :quantity, null: false, default: 0
      t.boolean     :is_in_stock, null: false, default: false
      t.boolean     :sync_needed, null: false, default: true
      t.timestamps
    end
  end
end
