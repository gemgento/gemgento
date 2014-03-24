class AddGenderToGemgentoUsers < ActiveRecord::Migration
  def change
    add_column :gemgento_users, :gender, :string
  end
end
