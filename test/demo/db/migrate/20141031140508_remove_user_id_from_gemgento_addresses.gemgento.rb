# This migration comes from gemgento (originally 20141030205035)
class RemoveUserIdFromGemgentoAddresses < ActiveRecord::Migration
  def change
    remove_column :gemgento_addresses, :user_id, :integer
  end
end
