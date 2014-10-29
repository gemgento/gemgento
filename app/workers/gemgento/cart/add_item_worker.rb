module Gemgento
  class Cart::AddItemWorker
    include Sidekiq::Worker

    def perform(line_item_id)
      line_item = Gemgento::LineItem.find(line_item_id)
      quote = line_item.itemizable

      response = API::SOAP::Checkout::Product.add(quote, [line_item])

      if !response.success?
        line_item.destroy
      end
    end

  end
end