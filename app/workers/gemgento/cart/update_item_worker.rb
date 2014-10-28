module Gemgento
  class Cart::UpdateItemWorker
    include Sidekiq::Worker

    def perform(line_item_id, old_quantity)
      line_item = Gemgento::LineItem.find(line_item_id)
      order = line_item.order

      response = API::SOAP::Checkout::Product.update(order, [line_item])

      if response.success?
        line_item.qty_ordered = old_quantity
        line_item.save

        order.cart_item_errors << {
            product_id: line_item.product_id,
            error: result
        }
        order.save
      end
    end

  end
end