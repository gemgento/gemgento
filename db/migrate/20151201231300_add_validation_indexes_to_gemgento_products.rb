class AddValidationIndexesToGemgentoProducts < ActiveRecord::Migration
  def change
    add_index :gemgento_products, :magento_id, unique: true
    add_index :gemgento_products, [:sku, :deleted_at], unique: true
  end
end
