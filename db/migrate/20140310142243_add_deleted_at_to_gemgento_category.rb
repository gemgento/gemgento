class AddDeletedAtToGemgentoCategory < ActiveRecord::Migration
  def change
    add_column :gemgento_categories, :deleted_at, :datetime
  end
end
