class CreateTableProductAttributeValues < ActiveRecord::Migration
  def change
    create_table :gemgento_product_attribute_values do |t|
      t.integer    :product_id
      t.integer    :product_attribute_id
      t.string     :value
      t.timestamps
    end
  end
end
