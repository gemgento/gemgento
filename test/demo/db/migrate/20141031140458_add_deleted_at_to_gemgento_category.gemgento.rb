# This migration comes from gemgento (originally 20140310142243)
class AddDeletedAtToGemgentoCategory < ActiveRecord::Migration
  def change
    add_column :gemgento_categories, :deleted_at, :datetime
  end
end
