class RemovePositionFromGemgentoProducts < ActiveRecord::Migration
  def up
    remove_column :gemgento_products, :position
  end

  def down
    add_column :gemgento_products, :position, :integer
  end
end
