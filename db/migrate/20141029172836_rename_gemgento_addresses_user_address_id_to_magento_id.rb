class RenameGemgentoAddressesUserAddressIdToMagentoId < ActiveRecord::Migration
  def change
    rename_column :gemgento_addresses, :user_address_id, :magento_id
  end
end
