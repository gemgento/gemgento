class CreateGemgentoProductsTags < ActiveRecord::Migration
  def up
    create_table :gemgento_products_tags, id: false do |t|
      t.references :product
      t.references :tag
    end

    add_index :gemgento_products_tags, [:product_id, :tag_id]
    add_index :gemgento_products_tags, :tag_id
  end

  def down
    drop_table :gemgento_products_tags
  end
end
