module Gemgento
  class ProductAttributeValue < ActiveRecord::Base
    belongs_to :product
    belongs_to :product_attribute

    default_scope -> { includes(:product_attribute) }
  end
end