# This migration comes from gemgento (originally 20140201185453)
class AddGenderToGemgentoUsers < ActiveRecord::Migration
  def change
    add_column :gemgento_users, :gender, :string
  end
end
