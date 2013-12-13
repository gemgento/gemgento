class CreateGemgentoCategoriesStores < ActiveRecord::Migration
  def change
    create_table :gemgento_categories_stores do |t|
      t.integer :category_id
      t.integer :store_id
    end

    add_column :gemgento_product_categories, :store_id, :integer
    drop_table :gemgento_categories_products
  end
end
