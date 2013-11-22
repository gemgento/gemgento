class AddStoreIdToProductAttributeOptions < ActiveRecord::Migration
  def change
    add_column :gemgento_product_attribute_options, :store_id, :integer
  end
end
