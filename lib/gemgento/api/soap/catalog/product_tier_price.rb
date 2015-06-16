module Gemgento
  module API
    module SOAP
      module Catalog
        class ProductTierPrice

          def self.info(product_id)
            message = {
                product: product_id,
                product_id: product_id,
                identifierType: 'id'
            }

            MagentoApi.create_call(:catalog_product_attribute_tier_price_info, message)
          end

        end
      end
    end
  end
end