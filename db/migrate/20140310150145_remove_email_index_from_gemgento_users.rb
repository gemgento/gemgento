class RemoveEmailIndexFromGemgentoUsers < ActiveRecord::Migration
  def up
    remove_index :gemgento_users, :email
    add_index :gemgento_users, [:email, :deleted_at], unique: true
  end

  def down
    remove_index :gemgento_users, [:email, :deleted_at]
    add_index :gemgento_users, :email, unique: true
  end
end
