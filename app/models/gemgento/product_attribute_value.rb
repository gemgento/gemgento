module Gemgento

  # @author Gemgento LLC
  class ProductAttributeValue < ActiveRecord::Base
    belongs_to :product
    belongs_to :product_attribute
    belongs_to :store
    belongs_to :product_attribute_option,
               ->(join_or_model) {
                 if join_or_model.is_a? ProductAttributeValue
                   where(product_attribute_id: join_or_model.product_attribute_id)
                 else
                   where('gemgento_product_attribute_options.product_attribute_id = gemgento_product_attribute_values.product_attribute_id')
                 end
               },
               foreign_key: 'value',
               primary_key: 'value'

    touch :product, after_touch: :touch_associations

    default_scope -> { includes(:product_attribute) }

    validates :product, :product_attribute, :store, presence: true
    validates :product_attribute, uniqueness: { scope: [:product, :store] }
  end
end