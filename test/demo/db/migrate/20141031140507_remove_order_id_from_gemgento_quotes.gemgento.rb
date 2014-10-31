# This migration comes from gemgento (originally 20141030204444)
class RemoveOrderIdFromGemgentoQuotes < ActiveRecord::Migration
  def change
    remove_column :gemgento_quotes, :order_id, :integer
  end
end
