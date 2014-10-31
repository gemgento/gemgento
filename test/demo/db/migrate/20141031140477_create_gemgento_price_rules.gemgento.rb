# This migration comes from gemgento (originally 20140724152337)
class CreateGemgentoPriceRules < ActiveRecord::Migration
  def change
    create_table :gemgento_price_rules do |t|
      t.integer :magento_id
      t.string :name
      t.text :description
      t.datetime :from_date
      t.datetime :to_date
      t.boolean :is_active, default: false, null: false
      t.boolean :stop_rules_processing, default: true, null: false
      t.integer :sort_order
      t.string :simple_action
      t.decimal :discount_amount
      t.boolean :sub_is_enable, default: false, null: false
      t.string :sub_simple_action
      t.decimal :sub_discount_amount
      t.text :conditions
    end
  end
end
