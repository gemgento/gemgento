module Gemgento
  class Search

    def self.products(term)
      magento_ids = API::SOAP::Catalog::Search.results(term)
      products = Product.where(magento_id: magento_ids)

      return products
    end

  end
end