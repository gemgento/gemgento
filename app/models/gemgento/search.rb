module Gemgento
  class Search

    def self.products(term)
      products = []
      Rails.logger.info Gemgento::API::SOAP::Catalog::Search.results(term).inspect
      Gemgento::API::SOAP::Catalog::Search.results(term).each do |magento_id|
        products << Gemgento::Product.find_by(magento_id: magento_id)
      end

      return products
    end

  end
end