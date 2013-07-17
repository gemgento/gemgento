class AddUnencryptedPasswordColumnToGemgentoUsers < ActiveRecord::Migration
  def up
    add_column :gemgento_users, :unencrypted_password, :string
  end

  def down
    remove_column :gemgento_user, :unencrypted_password
  end
end
