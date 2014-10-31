# This migration comes from gemgento (originally 20131122145637)
class RenameAttributeSetJoinTableColumns < ActiveRecord::Migration
  def up
    rename_column :gemgento_attribute_set_attributes, :attribute_set_id, :product_attribute_set_id
    rename_column :gemgento_attribute_set_attributes, :attribute_id, :product_attribute_id
  end

  def down
    rename_column :gemgento_attribute_set_attributes, :product_attribute_set_id, :attribute_set_id
    rename_column :gemgento_attribute_set_attributes, :product_attribute_id, :attribute_id
  end
end
