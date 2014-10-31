# This migration comes from gemgento (originally 20141029172700)
class RemoveGemgentoAddressesOrderId < ActiveRecord::Migration
  def change
    remove_reference :gemgento_addresses, :order
  end
end
