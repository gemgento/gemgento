class AddDeletedAtToGemgentoProducts < ActiveRecord::Migration
  def self.up
    add_column :gemgento_products, :deleted_at, :datetime
  end

  def self.down
    remove_column :gemgento_products, :deleted_at
  end
end
