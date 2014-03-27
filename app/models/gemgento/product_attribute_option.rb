module Gemgento
  class ProductAttributeOption < ActiveRecord::Base
    belongs_to :product_attribute
    belongs_to :store

    has_many :product_attribute_values,
             foreign_key: 'value',
             primary_key: 'value',
             conditions: Proc.new { |join_association|
               if join_association
                 'gemgento_product_attribute_values.product_attribute_id = product_attribute_id'
               else
                 { product_attribute_id: product_attribute_id }
               end
             }
    has_many :products, through: :product_attribute_values

    default_scope -> { order(:order) }

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