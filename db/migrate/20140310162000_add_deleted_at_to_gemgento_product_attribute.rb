class AddDeletedAtToGemgentoProductAttribute < ActiveRecord::Migration
  def change
    add_column :gemgento_product_attributes, :deleted_at, :datetime
  end
end
