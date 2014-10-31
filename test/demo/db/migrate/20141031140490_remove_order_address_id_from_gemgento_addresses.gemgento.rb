# This migration comes from gemgento (originally 20141027191313)
class RemoveOrderAddressIdFromGemgentoAddresses < ActiveRecord::Migration
  def change
    remove_column :gemgento_addresses, :order_address_id, :integer
  end
end
