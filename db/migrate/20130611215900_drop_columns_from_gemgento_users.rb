class DropColumnsFromGemgentoUsers < ActiveRecord::Migration
  def change
    remove_columns :gemgento_users, :code, :increment_id
  end
end
