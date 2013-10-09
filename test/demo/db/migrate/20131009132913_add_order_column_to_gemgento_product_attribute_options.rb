class AddOrderColumnToGemgentoProductAttributeOptions < ActiveRecord::Migration
  def change
    add_column :gemgento_product_attribute_options, :order, :integer
  end
end
