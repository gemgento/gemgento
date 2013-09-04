class CreateAttributeSetAttributeRelationsTable < ActiveRecord::Migration
  def change
    create_table "gemgento_attribute_set_attributes", id: false, force: true do |t|
      t.integer "product_attribute_set_id", default: 0, null: false
      t.integer "product_attribute_id", default: 0, null: false
    end
  end
end
