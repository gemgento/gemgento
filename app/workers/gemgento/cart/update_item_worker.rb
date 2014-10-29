module Gemgento
  class Cart::UpdateItemWorker
    include Sidekiq::Worker

    def perform(line_item_id, old_quantity)
      line_item = Gemgento::LineItem.find(line_item_id)
      quote = line_item.itemizable

      response = API::SOAP::Checkout::Product.update(quote, [line_item])

      if !response.success?
        line_item.qty_ordered = old_quantity
        line_item.save
      end
    end

  end
end