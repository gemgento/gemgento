class CreateTableGemgentoCategories < ActiveRecord::Migration
  def change
    create_table :gemgento_categories do |t|
      t.integer    :magento_id
      t.string     :name
      t.string     :url_key
      t.integer    :parent_id
      t.integer    :position
      t.boolean    :is_active
      t.timestamps
    end
  end
end
