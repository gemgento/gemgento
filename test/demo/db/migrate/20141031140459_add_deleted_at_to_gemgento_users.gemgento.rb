# This migration comes from gemgento (originally 20140310144408)
class AddDeletedAtToGemgentoUsers < ActiveRecord::Migration
  def change
    add_column :gemgento_users, :deleted_at, :datetime
  end
end
