class CreateGemgentoUserAddress < ActiveRecord::Migration
  def change
    create_table :gemgento_user_addresses do |t|
      t.integer :magento_id
      t.references :user, index: true
      t.references :address, index: true
      t.boolean :is_default_billing, default: false
      t.boolean :is_default_shipping, default: false
    end
  end
end
