# This migration comes from gemgento (originally 20140730192804)
class CreateGemgentoRecurringProfiles < ActiveRecord::Migration
  def change
    create_table :gemgento_recurring_profiles do |t|
      t.integer :magento_id
      t.string :state
      t.references :user, index: true
      t.references :store, index: true
      t.string :method_code
      t.integer :reference_id
      t.string :subscriber_name
      t.datetime :start_datetime
      t.string :internal_reference_id
      t.string :schedule_description
      t.string :period_unit
      t.integer :period_frequency
      t.decimal :billing_amount
      t.string :currency_code
      t.decimal :shipping_amount
      t.decimal :tax_amount
      t.text :order_info
      t.text :order_item_info
      t.text :billing_address_info
      t.text :shipping_address_info
      t.text :profile_vendor_info
      t.text :additional_info
    end
  end
end
