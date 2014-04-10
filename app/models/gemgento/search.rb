module Gemgento
  class Search

    def self.products(term)
      magento_ids = Gemgento::API::SOAP::Catalog::Search.results(term)
      products = Gemgento::Product.where(magento_id: magento_ids)

      return products
    end

  end
end