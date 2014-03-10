class AddDeletedAtToGemgentoUsers < ActiveRecord::Migration
  def change
    add_column :gemgento_users, :deleted_at, :datetime
  end
end
