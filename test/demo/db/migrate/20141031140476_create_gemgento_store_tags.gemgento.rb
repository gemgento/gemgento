# This migration comes from gemgento (originally 20140711135514)
class CreateGemgentoStoreTags < ActiveRecord::Migration
  def change
    create_table :gemgento_store_tags do |t|
      t.references :store, index: true
      t.references :tag, index: true
      t.integer :base_popularity, default: 0
    end
  end
end
