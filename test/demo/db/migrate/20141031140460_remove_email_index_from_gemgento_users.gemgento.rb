# This migration comes from gemgento (originally 20140310150145)
class RemoveEmailIndexFromGemgentoUsers < ActiveRecord::Migration
  def up
    remove_index :gemgento_users, :email
    add_index :gemgento_users, [:email, :deleted_at], unique: true, name: 'users_email_deleted_index'
  end

  def down
    remove_index :gemgento_users, [:email, :deleted_at], name: 'users_email_deleted_index'
    add_index :gemgento_users, :email, unique: true
  end
end
