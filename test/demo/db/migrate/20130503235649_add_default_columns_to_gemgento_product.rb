class AddDefaultColumnsToGemgentoProduct < ActiveRecord::Migration
  def change
    add_column :gemgento_products, :sku, :string
    add_column :gemgento_products, :set, :string
    add_column :gemgento_products, :store_view, :string
    add_column :gemgento_products, :sync_needed, :boolean, null: false, default: true
  end
end
