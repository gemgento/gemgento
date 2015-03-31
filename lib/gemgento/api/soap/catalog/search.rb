module Gemgento
  module API
    module SOAP
      module Catalog
        class Search

          def self.results(query)
            response = MagentoApi.create_call(:product_search_results, {query: query})

            if response.success?
              result = response.body[:result][:item]
              if result.nil?
                return []
              else
                result = [result] unless result.is_a? Array
                return result
              end
            else
              return []
            end
          end

        end
      end
    end
  end
end