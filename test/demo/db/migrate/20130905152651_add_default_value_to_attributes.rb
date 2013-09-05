class AddDefaultValueToAttributes < ActiveRecord::Migration
  def up
    add_column :gemgento_product_attributes, :default_value, :text
  end

  def down
    remove_column :gemgento_product_attributes, :default_value
  end
end
