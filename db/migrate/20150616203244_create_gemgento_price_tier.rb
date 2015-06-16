class CreateGemgentoPriceTier < ActiveRecord::Migration
  def change
    create_table :gemgento_price_tiers do |t|
      t.references :product, index: true
      t.references :store, index: true
      t.references :user_group, index: true
      t.float :quantity
      t.float :price
    end
  end
end
