module Gemgento
  class Cart::AddItemWorker
    include Sidekiq::Worker

    def perform(line_item_id)
      line_item = Gemgento::LineItem.find(line_item_id)

      begin
        response = API::SOAP::Checkout::Product.add(line_item.itemizable, [line_item])
        destroy_line_item(line_item) unless response.success?
      rescue
        destroy_line_item(line_item)
      end
    end

    def destroy_line_item(line_item)
      Gemgento::LineItem.skip_callback(:destroy, :before, :destroy_magento_quote_item)
      line_item.destroy
      Gemgento::LineItem.set_callback(:destroy, :before, :destroy_magento_quote_item)
    end

  end
end