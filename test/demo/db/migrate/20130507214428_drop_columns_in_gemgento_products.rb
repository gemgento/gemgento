class DropColumnsInGemgentoProducts < ActiveRecord::Migration
  def up
    remove_column :gemgento_products, :name
    remove_column :gemgento_products, :url_key
    remove_column :gemgento_products, :price
  end

  def down
    add_column  :gemgento_products, :name, :string
    add_column  :gemgento_products, :url_key, :string
    add_column  :gemgento_products, :price, :decimal
  end
end
