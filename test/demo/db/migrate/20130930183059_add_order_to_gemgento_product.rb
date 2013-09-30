class AddOrderToGemgentoProduct < ActiveRecord::Migration
  def up
    add_column :gemgento_products, :position, :integer
  end

  def down
    remove_column :gemgento_products, :position
  end
end
