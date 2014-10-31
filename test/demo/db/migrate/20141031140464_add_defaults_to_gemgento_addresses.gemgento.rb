# This migration comes from gemgento (originally 20140422140433)
class AddDefaultsToGemgentoAddresses < ActiveRecord::Migration
  def change
    rename_column :gemgento_addresses, :is_default, :is_default_billing
    add_column :gemgento_addresses, :is_default_shipping, :boolean, default: false
  end
end
