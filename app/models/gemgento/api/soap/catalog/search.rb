module Gemgento
  module API
    module SOAP
      module Catalog
        class Search

          def self.results(query)
            response = Gemgento::Magento.create_call(:product_search_results, {query: query})

            if response.success?
              result = response.body[:result][:item]
              result = [result] unless result.is_a? Array
              return result
            else
              return false
            end
          end

        end
      end
    end
  end
end