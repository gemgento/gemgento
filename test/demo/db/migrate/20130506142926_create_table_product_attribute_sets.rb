class CreateTableProductAttributeSets < ActiveRecord::Migration

  def change
    create_table :gemgento_product_attribute_sets do |t|
      t.integer    :magento_id
      t.string     :name
      t.timestamps
    end

  end
end
