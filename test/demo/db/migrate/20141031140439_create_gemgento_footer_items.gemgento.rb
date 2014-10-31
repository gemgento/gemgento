# This migration comes from gemgento (originally 20140109165822)
class CreateGemgentoFooterItems < ActiveRecord::Migration
  def change
    create_table :gemgento_footer_items, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.integer :position
      t.string :url

      t.timestamps
    end
  end
end
