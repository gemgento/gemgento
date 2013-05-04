class CreateTableGemgentoCategoriesProducts < ActiveRecord::Migration
  def change
    create_table :gemgento_categories_products do |t|
      t.integer    :product_id
      t.integer    :category_id
    end
  end
end
