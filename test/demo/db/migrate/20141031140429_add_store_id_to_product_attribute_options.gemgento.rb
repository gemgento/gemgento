# This migration comes from gemgento (originally 20131122133642)
class AddStoreIdToProductAttributeOptions < ActiveRecord::Migration
  def change
    add_column :gemgento_product_attribute_options, :store_id, :integer
  end
end
