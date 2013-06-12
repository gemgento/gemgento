class AddIndexToGemgentoUsers < ActiveRecord::Migration
  def change
    add_index :gemgento_users, :magento_id, unique: true
  end
end
