class CreateTableGemgentoProductAttributeOption < ActiveRecord::Migration
  def change
    create_table :gemgento_product_attribute_options do |t|
      t.integer    :product_attribute_id
      t.string     :label
      t.string     :value
      t.boolean    :sync_needed, null: false, default: true
      t.timestamps
    end
  end
end
