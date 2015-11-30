class RemoveSyncNeededFromGemgentoProducts < ActiveRecord::Migration
  def change
    remove_column :gemgento_products, :sync_needed
  end
end
