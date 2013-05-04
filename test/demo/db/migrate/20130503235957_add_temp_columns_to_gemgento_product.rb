class AddTempColumnsToGemgentoProduct < ActiveRecord::Migration
  def change
    add_column :gemgento_products, :quality, :string
    add_column :gemgento_products, :design, :string
    add_column :gemgento_products, :color, :string
    add_column :gemgento_products, :size, :string
  end
end
