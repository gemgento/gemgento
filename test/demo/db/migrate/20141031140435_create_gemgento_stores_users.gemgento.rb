# This migration comes from gemgento (originally 20131220141725)
class CreateGemgentoStoresUsers < ActiveRecord::Migration
  def up
    create_table :gemgento_stores_users, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :store_id
      t.integer :user_id
    end

    remove_column :gemgento_users, :store_id
  end

  def down
    drop_table :gemgento_stores_users
    add_column :gemgento_users, :store_id, :integer
  end
end
