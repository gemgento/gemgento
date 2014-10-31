# This migration comes from gemgento (originally 20140926153739)
class UpdateGemgentoRecurringProfileDecimals < ActiveRecord::Migration
  def change
    change_column :gemgento_recurring_profiles, :billing_amount, :decimal, precision: 8, scale: 2
    change_column :gemgento_recurring_profiles, :shipping_amount, :decimal, precision: 8, scale: 2
    change_column :gemgento_recurring_profiles, :tax_amount, :decimal, precision: 8, scale: 2
  end
end
