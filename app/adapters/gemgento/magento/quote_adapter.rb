module Gemgento
  class Magento::QuoteAdapter

    def self.find(quote_id, store_id = nil)
      response = Gemgento::API::SOAP::Checkout::Cart.info(quote_id, store_id)

      if response.success?
        return response.body[:result]
      else
        return nil
      end
    end

  end
end


