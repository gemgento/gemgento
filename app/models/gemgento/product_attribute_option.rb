module Gemgento
  class ProductAttributeOption < ActiveRecord::Base
    belongs_to :product_attribute
  
    private

      # Push local product changes to magento
      def sync_local_to_magento
        if self.sync_needed
          if !self.magento_id
            API::SOAP::Catalog::ProductAttributeOption.create(self)
          else
            API::SOAP::Catalog::ProductAttributeOption.update(self)
          end

          self.sync_needed = false
          self.save
        end
      end
  end
end