class CreateTableGemgentoUser < ActiveRecord::Migration
  def change
    create_table :gemgento_users do |t|
      t.integer   :magento_id, null: false, unique: true
      t.string    :code
      t.string    :increment_id
      t.integer   :store_id, null: false
      t.string    :created_in
      t.string    :email
      t.string    :fname
      t.string    :lname
      t.string    :mname
      t.string    :lname
      t.integer   :group_id
      t.string    :prefix
      t.string    :suffix
      t.date      :dob
      t.string    :taxvat
      t.boolean   :confirmation
      t.string    :password
      t.boolean   :sync_needed, null: false, default: true
      t.timestamps
    end
  end
end
