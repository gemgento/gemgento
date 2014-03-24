class AddStoresToProductAttributeValues < ActiveRecord::Migration
  def change
    add_column :gemgento_product_attribute_values, :store_id, :integer
  end
end
