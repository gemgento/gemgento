# This migration comes from gemgento (originally 20141029172836)
class RenameGemgentoAddressesUserAddressIdToMagentoId < ActiveRecord::Migration
  def change
    rename_column :gemgento_addresses, :user_address_id, :magento_id
  end
end
