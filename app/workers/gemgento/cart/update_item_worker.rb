module Gemgento
  class Cart::UpdateItemWorker
    include Sidekiq::Worker

    def perform(order_item_id, old_quantity)
      order_item = Gemgento::OrderItem.find(order_item_id)
      order = order_item.order

      response = API::SOAP::Checkout::Product.update(order, [order_item])

      if response.success?
        order_item.qty_ordered = old_quantity
        order_item.save

        order.cart_item_errors << {
            product_id: order_item.product_id,
            error: result
        }
        order.save
      end
    end

  end
end