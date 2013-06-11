class CreateTableGemgentoRegions < ActiveRecord::Migration
  def change
    create_table :gemgento_regions do |t|
      t.integer   :magento_id, null: false
      t.string    :code
      t.string    :name
      t.integer   :country_id
      t.timestamps
    end
  end
end