class CreateGemgentoPriceRulesUserGroups < ActiveRecord::Migration
  def up
    create_table :gemgento_price_rules_user_groups do |t|
      t.references :price_rule
      t.references :user_group
    end

    add_index :gemgento_price_rules_user_groups, [:price_rule_id, :user_group_id], name: 'price_rule_user_group_index'
    add_index :gemgento_price_rules_user_groups, :user_group_id, name: 'user_group_index'
  end

  def down
    drop_table :gemgento_price_rules_user_groups
  end
end
