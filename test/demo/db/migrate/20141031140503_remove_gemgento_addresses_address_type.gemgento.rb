# This migration comes from gemgento (originally 20141029172426)
class RemoveGemgentoAddressesAddressType < ActiveRecord::Migration
  def change
    remove_column :gemgento_addresses, :address_type, :string
  end
end
