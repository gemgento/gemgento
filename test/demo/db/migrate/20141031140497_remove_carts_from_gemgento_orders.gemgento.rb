# This migration comes from gemgento (originally 20141028203943)
class RemoveCartsFromGemgentoOrders < ActiveRecord::Migration
  def up
    Gemgento::Order.where(state: 'cart').destroy_all
  end

  def down
    # don't do nothin'
  end
end
