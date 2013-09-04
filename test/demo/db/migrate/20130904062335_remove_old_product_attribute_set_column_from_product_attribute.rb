class RemoveOldProductAttributeSetColumnFromProductAttribute < ActiveRecord::Migration
  def change
    remove_column :gemgento_product_attributes, :product_attribute_set_id
  end
end
