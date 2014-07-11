class CreateGemgentoTags < ActiveRecord::Migration
  def change
    create_table :gemgento_tags do |t|
      t.integer :magento_id
      t.string :name
      t.string :status, default: 0
      t.boolean :sync_needed, default: false
    end
  end
end
