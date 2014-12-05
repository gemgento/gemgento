module Gemgento
  class Cart::AddItemWorker
    include Sidekiq::Worker

    def perform(line_item_id)
      line_item = Gemgento::LineItem.find(line_item_id)
      quote = line_item.itemizable

      response = API::SOAP::Checkout::Product.add(quote, [line_item])

      if !response.success?
        Gemgento::LineItem.skip_callback(:destroy, :before, :destroy_magento_quote_item)
        line_item.destroy
        Gemgento::LineItem.set_callback(:destroy, :before, :destroy_magento_quote_item)
      end
    end

  end
end