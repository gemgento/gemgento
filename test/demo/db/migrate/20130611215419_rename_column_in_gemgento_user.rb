class RenameColumnInGemgentoUser < ActiveRecord::Migration
  def up
    rename_column :gemgento_users, :group_id, :user_group_id
  end

  def down
    rename_column :gemgento_users, :user_group_id, :group_id
  end
end
