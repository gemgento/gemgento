class ConvertFloatToDecimalOnGemgentoPriceTiers < ActiveRecord::Migration
  def up
    change_column :gemgento_price_tiers, :price, :decimal, precision: 5, scale: 2
    change_column :gemgento_price_tiers, :quantity, :decimal, precision: 5, scale: 2
  end

  def down
    change_column :gemgento_price_tiers, :price, :float
    change_column :gemgento_price_tiers, :quantity, :float
  end
end
