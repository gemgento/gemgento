class CreateTableGemgentoStore < ActiveRecord::Migration
  def change
    create_table :gemgento_stores do |t|
      t.integer   :magento_id, null: false
      t.string    :code
      t.integer   :group_id
      t.string    :name
      t.integer   :sort_order
      t.boolean   :is_active, null: false, default: true
      t.timestamps
    end

    add_index :gemgento_stores, :magento_id, unique: true
  end
end
