class RemoveColumnsFromGemgentoProducts < ActiveRecord::Migration
  def up
    remove_column :gemgento_products, :quality
    remove_column :gemgento_products, :design
    remove_column :gemgento_products, :color
    remove_column :gemgento_products, :size
  end

  def down
    add_column  :gemgento_products, :quality, :string
    add_column  :gemgento_products, :design, :string
    add_column  :gemgento_products, :color, :string
    add_column  :gemgento_products, :size, :string
  end
end
