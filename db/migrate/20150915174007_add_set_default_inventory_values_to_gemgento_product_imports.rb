class AddSetDefaultInventoryValuesToGemgentoProductImports < ActiveRecord::Migration
  def change
    add_column :gemgento_product_imports, :set_default_inventory_values, :boolean, default: false
  end
end
