module Gemgento
  class ProductAttributeValue < ActiveRecord::Base
    belongs_to :product
    belongs_to :product_attribute
    belongs_to :store

    has_many :product_attribute_options

    default_scope -> { includes(:product_attribute) }

    after_save :touch_product

    private

    def touch_product
      Gemgento::TouchProduct.perform_async([self.product.id]) if self.changed?
    end
  end
end