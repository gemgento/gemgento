class AddVisibilityToProductImport < ActiveRecord::Migration
  def up
    add_column :gemgento_product_imports, :simple_product_visibility, :integer
    add_column :gemgento_product_imports, :configurable_product_visibility, :integer
  end

  def down
    remove_column :gemgento_product_imports, :simple_product_visibility
    remove_column :gemgento_product_imports, :configurable_product_visibility
  end
end
