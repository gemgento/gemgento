# This migration comes from gemgento (originally 20140730192852)
class CreateGemgentoOrdersRecurringProfiles < ActiveRecord::Migration
  def up
    create_table :gemgento_orders_recurring_profiles, id: false do |t|
      t.references :order
      t.references :recurring_profile
    end

    add_index :gemgento_orders_recurring_profiles, [:order_id, :recurring_profile_id], name: 'order_recurring_profile_index'
    add_index :gemgento_orders_recurring_profiles, [:recurring_profile_id], name: 'recurring_profile_index'
  end

  def down
    drop_table :gemgento_orders_recurring_profiles

  end
end
