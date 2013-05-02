class CreateTableGemgentoAssets < ActiveRecord::Migration
  def change
    create_table :gemgento_assets do |t|
      t.integer    :product_id
      t.string     :type
      t.string     :url
      t.integer    :position
      t.timestamps
    end
  end
end
