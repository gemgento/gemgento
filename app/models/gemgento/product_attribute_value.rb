module Gemgento
  class ProductAttributeValue < ActiveRecord::Base
    belongs_to :product
    belongs_to :product_attribute
    belongs_to :store
    belongs_to :product_attribute_option,
               ->(join_or_model) {
                 if join_or_model.is_a? Gemgento::ProductAttributeValue
                   where(product_attribute_id: join_or_model.product_attribute_id)
                 else
                   where('gemgento_product_attribute_options.product_attribute_id = gemgento_product_attribute_values.product_attribute_id')
                 end
               },
               foreign_key: 'value',
               primary_key: 'value'

    default_scope -> { includes(:product_attribute) }

    after_save :touch_product

    private

    def touch_product
      affects_cache_expiration = %w[special_from_date special_to_date special_price].include?(self.product_attribute.code)
      Gemgento::TouchProduct.perform_async([self.product.id], affects_cache_expiration) if self.changed?
    end
  end
end