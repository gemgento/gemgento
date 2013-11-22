class AddDefaultAdminStore < ActiveRecord::Migration
  def up
    store = Gemgento::Store.new
    store.magento_id = 0
    store.website_id = 0
    store.sort_order = 0
    store.group_id = 0
    store.code = 'admin'
    store.name = 'Admin'
    store.is_active = true
    store.save
  end

  def down
    Gemgento::Store.find_by(magento_id: 0).destroy
  end
end
