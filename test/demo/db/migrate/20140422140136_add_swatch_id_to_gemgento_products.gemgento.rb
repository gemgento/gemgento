# This migration comes from gemgento (originally 20140117213809)
class AddSwatchIdToGemgentoProducts < ActiveRecord::Migration
  def change
    add_column :gemgento_products, :swatch_id, :integer
  end
end
