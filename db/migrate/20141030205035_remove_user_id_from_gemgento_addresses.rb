class RemoveUserIdFromGemgentoAddresses < ActiveRecord::Migration
  def change
    remove_column :gemgento_addresses, :user_id, :integer
  end
end
