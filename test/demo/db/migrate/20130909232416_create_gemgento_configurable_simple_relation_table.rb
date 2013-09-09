class CreateGemgentoConfigurableSimpleRelationTable < ActiveRecord::Migration
  def change
    create_table "gemgento_configurable_simple_relations", id: false, force: true do |t|
      t.integer "configurable_product_id", default: 0, null: false
      t.integer "simple_product_id", default: 0, null: false
    end
  end
end
