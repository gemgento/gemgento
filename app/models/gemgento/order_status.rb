module Gemgento
  class OrderStatus < ActiveRecord::Base
    belongs_to :order

    def self.sync_magento_to_local(source, order)
      order_status = OrderStatus.find_or_initialize_by(order: order, status: source[:status], comment: source[:comment])
      order_status.order = order
      order_status.status = source[:status]
      order_status.is_active = source[:is_active]
      order_status.is_customer_notified = source[:is_customer_notified]
      order_status.comment = source[:comment]
      order_status.created_at = source[:created_at]
      order_status.save

      order_status
    end
  end
end