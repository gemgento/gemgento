module Gemgento
  class ProductAttributeValue < ActiveRecord::Base
    belongs_to :product
    belongs_to :product_attribute
    belongs_to :store
    belongs_to :product_attribute_option,
               foreign_key: 'value',
               primary_key: 'value',
               conditions: Proc.new { |join_association|
                 if join_association
                   'gemgento_product_attribute_options.product_attribute_id = product_attribute_id'
                 else
                   { product_attribute_id: product_attribute_id }
                 end
               }

    default_scope -> { includes(:product_attribute) }

    after_save :touch_product

    private

    def touch_product
      Gemgento::TouchProduct.perform_async([self.product.id]) if self.changed?
    end
  end
end