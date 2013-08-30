class ChangeGemgentoOrderStatusCommentToText < ActiveRecord::Migration
  def change
    change_column :gemgento_order_statuses, :comment, :text
  end
end
