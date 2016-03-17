module Gemgento
  class Magento::ProductAdapter
    include MagentoAdapter

    def self.find_by(attributes)
      response = Gemgento::API::SOAP::Catalog::Product.list filters(attributes)

      if response.body_overflow[:store_view].first[:item]

        if response.body_overflow[:store_view].first[:item].is_a? Array
          return response.body_overflow[:store_view].first[:item].first

        else
          return response.body_overflow[:store_view].first[:item]
        end

      else
        return nil
      end
    end

  end
end

