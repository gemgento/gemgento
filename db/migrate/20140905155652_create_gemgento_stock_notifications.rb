class CreateGemgentoStockNotifications < ActiveRecord::Migration
  def change
    create_table :gemgento_stock_notifications do |t|
      t.integer :product_id
      t.string :product_name
      t.string :product_url
      t.string :name
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
