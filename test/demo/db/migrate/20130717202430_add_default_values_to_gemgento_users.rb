class AddDefaultValuesToGemgentoUsers < ActiveRecord::Migration
  def change
    change_column :gemgento_users, :magento_id, :integer, null: true, default: nil
    change_column :gemgento_users, :store_id, :integer, null: true, default: nil
  end
end
