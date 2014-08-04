class AddCacheExpiresAtToGemgentoProducts < ActiveRecord::Migration
  def change
    add_column :gemgento_products, :cache_expires_at, :datetime
  end
end
