class AddColumnToGemgentoProducts < ActiveRecord::Migration
  def change
    add_column :gemgento_products, :parent_id, :integer
  end
end
