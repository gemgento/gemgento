class RemoveChildrenFromGemgentoCategories < ActiveRecord::Migration
  def up
    remove_column :gemgento_categories, :children
  end

  def down
    add_column :gemgento_categories, :children, :string
  end
end
