module Gemgento
  class Cart::AddItemWorker
    include Sidekiq::Worker

    def perform(order_item_id)
      order_item = Gemgento::OrderItem.find(order_item_id)
      order = order_item.order

      order.push_cart if order.magento_quote_id.nil?

      unless order.magento_quote_id.nil?
        result = API::SOAP::Checkout::Product.add(order, [order_item])

        if result != true
          order.cart_item_errors << {
            product_id: order_item.product_id,
            error: result
          }
          order.save

          order_item.destroy
        end
      end
    end
  end
end