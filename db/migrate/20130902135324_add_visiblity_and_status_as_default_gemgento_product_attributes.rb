class AddVisiblityAndStatusAsDefaultGemgentoProductAttributes < ActiveRecord::Migration
  def change
    add_column :gemgento_products, :status, :boolean, default: true
    add_column :gemgento_products, :visibility, :integer, default: 4
  end
end
