# This migration comes from gemgento (originally 20140127215049)
class AddCurrencyCodeToGemgentoStores < ActiveRecord::Migration
  def change
    add_column :gemgento_stores, :currency_code, :string, default: 'usd'
  end
end
