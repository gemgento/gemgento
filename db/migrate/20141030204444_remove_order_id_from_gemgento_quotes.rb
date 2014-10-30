class RemoveOrderIdFromGemgentoQuotes < ActiveRecord::Migration
  def change
    remove_column :gemgento_quotes, :order_id, :integer
  end
end
