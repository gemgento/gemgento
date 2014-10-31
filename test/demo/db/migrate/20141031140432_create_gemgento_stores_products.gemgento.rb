# This migration comes from gemgento (originally 20131213161143)
class CreateGemgentoStoresProducts < ActiveRecord::Migration
  def up
    create_table :gemgento_stores_products, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :product_id
      t.integer :store_id
    end

    remove_column :gemgento_products, :store_id
  end

  def down
    drop_table :gemgento_stores_products
    add_column :gemgento_products, :store_id, :integer
  end
end
