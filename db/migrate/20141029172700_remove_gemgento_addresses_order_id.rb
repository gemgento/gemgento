class RemoveGemgentoAddressesOrderId < ActiveRecord::Migration
  def change
    remove_reference :gemgento_addresses, :order
  end
end
