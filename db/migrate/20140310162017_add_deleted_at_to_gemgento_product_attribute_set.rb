class AddDeletedAtToGemgentoProductAttributeSet < ActiveRecord::Migration
  def change
    add_column :gemgento_product_attribute_sets, :deleted_at, :datetime
  end
end
