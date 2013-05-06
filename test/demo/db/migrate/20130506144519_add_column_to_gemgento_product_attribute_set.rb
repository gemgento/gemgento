class AddColumnToGemgentoProductAttributeSet < ActiveRecord::Migration
  def change
    add_column  :gemgento_product_attribute_sets, :sync_needed, :boolean, null: false, default: true
  end
end
