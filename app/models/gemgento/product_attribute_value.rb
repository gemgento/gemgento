module Gemgento
  class ProductAttributeValue < ActiveRecord::Base
    belongs_to :product, touch: true
    belongs_to :product_attribute

    default_scope -> { includes(:product_attribute) }
  end
end