module Gemgento

  # @author Gemgento LLC
  class ProductAttributeOption < ActiveRecord::Base
    belongs_to :product_attribute
    belongs_to :store

    has_many :product_attribute_values,
              Proc.new { |join_or_model|
               if join_or_model.is_a? ProductAttributeOption
                 where(product_attribute_id: join_or_model.product_attribute_id)
               else
                 where('gemgento_product_attribute_values.product_attribute_id = gemgento_product_attribute_options.product_attribute_id')
               end
             },
             foreign_key: 'value',
             primary_key: 'value'
    has_many :products, through: :product_attribute_values

    before_save :sync_local_to_magento, if: -> { sync_needed? }

    default_scope -> { order(:order) }

    # Push local attribute option changes to magento.
    #
    # @return [Void]
    def sync_local_to_magento
      response = API::SOAP::Catalog::ProductAttribute.add_option(self, self.product_attribute)

      if response.success?
        self.sync_needed = false
        return true
      else
        errors.add(:base, response.body[:faultstring])
       return false
      end
    end
  end
end