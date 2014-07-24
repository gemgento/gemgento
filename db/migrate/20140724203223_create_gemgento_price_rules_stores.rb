class CreateGemgentoPriceRulesStores < ActiveRecord::Migration
  def up
    create_table :gemgento_price_rules_stores, id: false do |t|
      t.references :price_rule
      t.references :store
    end

    add_index :gemgento_price_rules_stores, [:price_rule_id, :store_id]
    add_index :gemgento_price_rules_stores, :store_id
  end

  def down
    drop_table :gemgento_price_rules_stores
  end
end
