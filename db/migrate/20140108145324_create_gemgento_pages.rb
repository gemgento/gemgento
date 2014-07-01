class CreateGemgentoPages < ActiveRecord::Migration
  def change
    create_table :gemgento_pages, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.text :description
      t.string :permalink
      t.text :body
      t.boolean :show_in_main_nav
      t.boolean :is_shop_landing
      t.integer :position

      t.timestamps
    end
  end
end
