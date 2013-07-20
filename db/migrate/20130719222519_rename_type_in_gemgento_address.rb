class RenameTypeInGemgentoAddress < ActiveRecord::Migration
  def change
    remove_column :gemgento_addresses, :type
  end
end
