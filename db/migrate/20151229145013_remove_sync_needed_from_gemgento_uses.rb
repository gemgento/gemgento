class RemoveSyncNeededFromGemgentoUses < ActiveRecord::Migration
  def change
    remove_column :gemgento_users, :sync_needed, :boolean
  end
end
