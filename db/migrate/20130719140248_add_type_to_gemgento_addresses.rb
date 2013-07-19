class AddTypeToGemgentoAddresses < ActiveRecord::Migration
  def change
    add_column :gemgento_addresses, :type, :string
    remove_column :gemgento_addresses, :is_default_shipping
    remove_column :gemgento_addresses, :is_default_billing
    add_column :gemgento_addresses, :is_default, :boolean, default: false
  end
end
