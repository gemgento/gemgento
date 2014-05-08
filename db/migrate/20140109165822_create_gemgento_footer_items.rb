class CreateGemgentoFooterItems < ActiveRecord::Migration
  def change
    create_table :gemgento_footer_items do |t|
      t.string :name
      t.integer :position
      t.string :url

      t.timestamps
    end
  end
end
