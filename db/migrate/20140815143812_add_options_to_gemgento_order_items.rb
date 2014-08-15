class AddOptionsToGemgentoOrderItems < ActiveRecord::Migration
  def change
    add_column :gemgento_order_items, :options, :text
  end
end
