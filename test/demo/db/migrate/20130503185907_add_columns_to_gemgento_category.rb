class AddColumnsToGemgentoCategory < ActiveRecord::Migration
  def change
    add_column :gemgento_categories, :all_children, :text
    add_column :gemgento_categories, :children, :string
    add_column :gemgento_categories, :children_count, :integer
  end
end
