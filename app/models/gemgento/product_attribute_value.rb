module Gemgento
  class ProductAttributeValue < ActiveRecord::Base
    belongs_to :product
    belongs_to :product_attribute

    default_scope -> { includes(:product_attribute) }

    after_save :touch_product

    private

    def touch_product
      self.product.update(updated_at: Time.now) if self.changed?
    end
  end
end