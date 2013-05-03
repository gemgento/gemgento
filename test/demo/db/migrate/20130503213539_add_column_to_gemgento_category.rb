class AddColumnToGemgentoCategory < ActiveRecord::Migration
  def change
    add_column :gemgento_categories, :include_in_menu, :boolean, null: false, default: true
  end
end
