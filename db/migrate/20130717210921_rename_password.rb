class RenamePassword < ActiveRecord::Migration
  def up
    rename_column :gemgento_users, :password, :magento_password
    remove_column :gemgentoo_users, :unencrypted_password
  end

  def down
    rename_column :gemgento_users, :magento_password, :password
    create_column :gemgento_users, :unencrypted_password, :string
  end
end
