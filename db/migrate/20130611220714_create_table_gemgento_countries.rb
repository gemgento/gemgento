class CreateTableGemgentoCountries < ActiveRecord::Migration
  def change
    create_table :gemgento_countries do |t|
      t.integer   :magento_id, null: false
      t.string    :iso2_code
      t.string    :iso3_code
      t.string    :name
      t.timestamps
    end
  end
end
