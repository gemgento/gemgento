# This migration comes from gemgento (originally 20131213163410)
class AddStoresToProductAttributeValues < ActiveRecord::Migration
  def change
    add_column :gemgento_product_attribute_values, :store_id, :integer
  end
end
