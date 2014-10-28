module Gemgento
  class Cart::AddItemWorker
    include Sidekiq::Worker

    def perform(line_item_id)
      line_item = Gemgento::LineItem.find(line_item_id)
      order = line_item.order

      order.push_cart if order.magento_quote_id.nil?

      unless order.magento_quote_id.nil?
        response = API::SOAP::Checkout::Product.add(order, [line_item])

        if response.success?
          order.cart_item_errors << {
            product_id: line_item.product_id,
            error: result
          }
          order.save

          line_item.destroy
        end
      end
    end

  end
end