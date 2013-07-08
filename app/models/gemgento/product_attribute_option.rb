module Gemgento
  class ProductAttributeOption < ActiveRecord::Base
    belongs_to :product_attribute

    # Push local product changes to magento
    def sync_local_to_magento
      if self.sync_needed
        API::SOAP::Catalog::ProductAttribute.add_option(self, self.product_attribute)
        self.sync_needed = false
        self.save
      end
    end
  end
end