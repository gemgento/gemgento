# This migration comes from gemgento (originally 20140310162017)
class AddDeletedAtToGemgentoProductAttributeSet < ActiveRecord::Migration
  def change
    add_column :gemgento_product_attribute_sets, :deleted_at, :datetime
  end
end
