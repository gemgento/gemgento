# This migration comes from gemgento (originally 20140310162000)
class AddDeletedAtToGemgentoProductAttribute < ActiveRecord::Migration
  def change
    add_column :gemgento_product_attributes, :deleted_at, :datetime
  end
end
