module Gemgento
  class Magento::OrderStatusAdapter

    attr_accessor :source, :order

    # @param source [Hash]
    # @param order [Gemgento::Order]
    def initialize(source, order)
      @source = source
      @order = order
    end
    
    def import
      order_status = Gemgento::OrderStatus.find_or_initialize_by(order_id: self.order.id, status: self.source[:status], comment: self.source[:comment])
      order_status.is_active = self.source[:is_active]
      order_status.is_customer_notified = self.source[:is_customer_notified].to_i
      order_status.created_at = self.source[:created_at]
      order_status.save!

      order_status
    end

  end
end