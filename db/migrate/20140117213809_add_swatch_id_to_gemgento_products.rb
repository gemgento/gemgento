class AddSwatchIdToGemgentoProducts < ActiveRecord::Migration
  def change
    add_column :gemgento_products, :swatch_id, :integer
  end
end
