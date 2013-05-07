class UpdateColumnInGemgentoProductAttributeValues < ActiveRecord::Migration
  def up
    change_column :gemgento_product_attribute_values, :value, :text
  end

  def down
    change_column :gemgento_product_attribute_values, :value, :string
  end
end

