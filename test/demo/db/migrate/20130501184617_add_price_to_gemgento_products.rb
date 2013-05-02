class AddPriceToGemgentoProducts < ActiveRecord::Migration
  def change
    add_column :gemgento_products, :price, :decimal
  end
end
