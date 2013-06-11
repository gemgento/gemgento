class CreateGemgentoProducts < ActiveRecord::Migration
  
  def change
    create_table :gemgento_products do |t|
      t.integer    :magento_id
      t.string     :name
      t.string     :magento_type
      t.string     :url_key
      t.timestamps
    end

  end
end
