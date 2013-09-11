module Gemgento
  class ProductAttributeValue < ActiveRecord::Base
    belongs_to :product
    belongs_to :product_attribute

    default_scope include: [:product_attribute]
  end
end