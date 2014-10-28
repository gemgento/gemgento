class RemoveCartsFromGemgentoOrders < ActiveRecord::Migration
  def up
    Gemgento::Order.where(state: 'cart').destroy_all
  end

  def down
    # don't do nothin'
  end
end
