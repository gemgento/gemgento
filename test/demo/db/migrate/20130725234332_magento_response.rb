class MagentoResponse < ActiveRecord::Migration
  def change
    create_table :magento_responses do |t|
      t.text :request
      t.text :response
      t.timestamps
    end
  end
end
