# This migration comes from gemgento (originally 20141029152921)
class RenameGemgentoAddressIsDefaults < ActiveRecord::Migration
  def change
    rename_column :gemgento_addresses, :is_default_shipping, :is_shipping
    rename_column :gemgento_addresses, :is_default_billing, :is_billing
  end
end
