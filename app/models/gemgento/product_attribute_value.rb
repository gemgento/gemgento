module Gemgento
  class ProductAttributeValue < ActiveRecord::Base
    belongs_to :product
    belongs_to :product_attribute
    belongs_to :store
    belongs_to :product_attribute_option,
               ->(join_or_model) {
                 if join_or_model.is_a? JoinDependency::JoinAssociation
                   where('gemgento_product_attribute_options.product_attribute_id = gemgento_product_attribute_values.product_attribute_id')
                 else
                   where(product_attribute_id: join_or_model.product_attribute_id)
                 end
               },
               foreign_key: 'value',
               primary_key: 'value'

    default_scope -> { includes(:product_attribute) }

    after_save :touch_product

    private

    def touch_product
      Gemgento::TouchProduct.perform_async([self.product.id]) if self.changed?
    end
  end
end