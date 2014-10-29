class RemoveGemgentoAddressesAddressType < ActiveRecord::Migration
  def change
    remove_column :gemgento_addresses, :address_type, :string
  end
end
