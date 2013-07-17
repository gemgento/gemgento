class MergeGemgentoUsersWithDevise < ActiveRecord::Migration
  def change
    ## Database authenticatable
    change_column :gemgento_users, :email, :string, :null => false, :default => ""
    add_column :gemgento_users, :encrypted_password, :string, :null => false, :default => ""

    ## Recoverable
    add_column :gemgento_users, :reset_password_token, :string
    add_column :gemgento_users, :reset_password_sent_at, :datetime

    ## Rememberable
    add_column :gemgento_users, :remember_created_at, :datetime

    ## Trackable
    add_column :gemgento_users, :sign_in_count, :integer, :default => 0
    add_column :gemgento_users, :current_sign_in_at, :datetime
    add_column :gemgento_users, :last_sign_in_at, :datetime
    add_column :gemgento_users, :current_sign_in_ip, :string
    add_column :gemgento_users, :last_sign_in_ip, :string

    add_index :gemgento_users, :email,                :unique => true
    add_index :gemgento_users, :reset_password_token, :unique => true
  end
end
