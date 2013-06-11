class CreateTableGemgentoUserGroups < ActiveRecord::Migration
  def change
    create_table :gemgento_user_groups do |t|
      t.integer     :magento_id
      t.string      :code
      t.timestamps
    end
  end
end
