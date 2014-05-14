# This migration comes from gemgento (originally 20140129220352)
class CreateGemgentoSubscriber < ActiveRecord::Migration
  def change
    create_table :gemgento_subscribers do |t|
      t.string :fname
      t.string :lname
      t.string :email, :unique => true
      t.integer :country_id
      t.string :city
      t.timestamps
    end
  end
end
