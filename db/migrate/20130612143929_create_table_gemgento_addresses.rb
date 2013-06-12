class CreateTableGemgentoAddresses < ActiveRecord::Migration
  def change
    create_table :gemgento_addresses do |t|
      t.integer     :magento_id, null: false
      t.integer     :user_id, null: false
      t.string      :increment_id
      t.string      :city
      t.string      :company
      t.integer     :country_id
      t.string      :fax
      t.string      :fname
      t.string      :mname
      t.string      :lname
      t.string      :postcode
      t.string      :prefix
      t.string      :suffix
      t.string      :region_name
      t.integer     :region_id
      t.string      :street
      t.string      :telephone
      t.boolean     :is_default_billing, null: false, default: false
      t.boolean     :is_default_shipping, null: false, default: false
      t.boolean     :sync_needed, null: false, default: true
      t.timestamps
    end
  end
end
