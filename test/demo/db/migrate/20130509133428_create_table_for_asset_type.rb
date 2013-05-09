class CreateTableForAssetType < ActiveRecord::Migration
  def change
    create_table :gemgento_asset_types do |t|
      t.integer    :product_attribute_set_id
      t.string     :code
      t.string     :scope
      t.timestamps
    end
  end
end
