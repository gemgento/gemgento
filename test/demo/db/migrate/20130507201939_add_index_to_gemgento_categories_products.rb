class AddIndexToGemgentoCategoriesProducts < ActiveRecord::Migration
  def up
    remove_column :gemgento_categories_products, :id
    execute "ALTER TABLE  `gemgento_categories_products` ADD PRIMARY KEY (  `product_id` ,  `category_id` )"
  end

  def down
    execute "ALTER TABLE `gemgento_categories_products` DROP PRIMARY KEY"
    add_column :gemgento_categories_products, :id, :primary_key
  end
end
