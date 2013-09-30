class CreateGemgentoProductCategory < ActiveRecord::Migration
  def change
    create_table :gemgento_product_categories do |t|
      t.integer :category_id
      t.integer :product_id
      t.integer :position, :default => 1, :null => false
      t.timestamps
    end
  end
end
