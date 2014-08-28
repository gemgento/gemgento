class CreateAdminStore < ActiveRecord::Migration
  def up
    Gemgento::Store.create(magento_id: 0, code: 'admin', group_id: 0, website_id: 0, name: 'Admin', sort_order: 0, is_active: 1)
  end

  def down
    if store = Gemgento::Store.find_by(magento_id: 0)
      store.destroy
    end
  end
end
