module Gemgento
  class ProductAttribute < ActiveRecord::Base
    belongs_to :product_attribute_set
    has_many :product_attribute_values
    has_many :product_attribute_options
    has_and_belongs_to_many :configurable_products, -> { uniq } , join_table: 'gemgento_configurable_attributes', class_name: 'Product'
    after_save :sync_local_to_magento

    private

    # Push local product attribute set changes to Magento
    def sync_local_to_magento
      if self.sync_needed
        if !self.magento_id
          API::SOAP::Catalog::ProductAttribute.create(self)
        else
          API::SOAP::Catalog::ProductAttribute.update(self)
        end

        self.sync_needed = false
        self.save
      end
    end

  end
end